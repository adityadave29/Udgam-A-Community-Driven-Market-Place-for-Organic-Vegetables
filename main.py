#ifconfig | grep inet
#/opt/homebrew/bin/python3.10 -m venv venv
# source venv/bin/activate 
#uvicorn main:app --host 0.0.0.0 --port 8000 
import pandas as pd
import numpy as np
from lightfm import LightFM
from scipy.sparse import csr_matrix
import requests
from fastapi import FastAPI
from pydantic import BaseModel

# Supabase credentials
SUPABASE_URL = "https://wzcqzylxgphylogyzkzf.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Ind6Y3F6eWx4Z3BoeWxvZ3l6a3pmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzg4MTY0NTEsImV4cCI6MjA1NDM5MjQ1MX0._rbFNMFSz4keBi8oJ6gVbVnXRLswHOsRvHAsNVFt4TI"
HEADERS = {
    "apikey": SUPABASE_KEY,
    "Authorization": f"Bearer {SUPABASE_KEY}",
    "Content-Type": "application/json",
}

# Fetch interaction data
def fetch_interactions():
    url = f"{SUPABASE_URL}/rest/v1/farmersordersdetail?select=user_id,product_id,quantity"
    response = requests.get(url, headers=HEADERS)
    if response.status_code != 200:
        print(f"Failed to fetch interactions: {response.text}")
        return pd.DataFrame()
    data = response.json()
    df = pd.DataFrame(data)
    df_grouped = df.groupby(['user_id', 'product_id'])['quantity'].sum().reset_index()
    df_grouped.rename(columns={'quantity': 'interaction_strength'}, inplace=True)
    return df_grouped

# Fetch product features
def fetch_product_features():
    url = f"{SUPABASE_URL}/rest/v1/products?select=product_id,category&status=eq.Available"
    response = requests.get(url, headers=HEADERS)
    if response.status_code != 200:
        print(f"Failed to fetch products: {response.text}")
        return pd.DataFrame()
    data = response.json()
    return pd.DataFrame(data)

# Preprocess data
def preprocess_data(interactions_df, products_df):
    if interactions_df.empty or products_df.empty:
        print("No data to process!")
        return None, None, None, None, None
    
    valid_product_ids = interactions_df['product_id'].unique()
    products_df = products_df[products_df['product_id'].isin(valid_product_ids)]
    
    if products_df.empty:
        print("No matching products found!")
        return None, None, None, None, None
    
    user_ids = interactions_df['user_id'].unique()
    product_ids = products_df['product_id'].unique()
    user_id_map = {uid: i for i, uid in enumerate(user_ids)}
    product_id_map = {pid: i for i, pid in enumerate(product_ids)}

    rows = interactions_df['user_id'].map(user_id_map)
    cols = interactions_df['product_id'].map(product_id_map)
    data = interactions_df['interaction_strength']
    interaction_matrix = csr_matrix((data, (rows, cols)), shape=(len(user_ids), len(product_ids)))

    item_features = csr_matrix(np.eye(len(product_ids)))
    
    return interaction_matrix, item_features, user_id_map, product_id_map, product_ids

# Train model
def train_model(interaction_matrix, item_features):
    if interaction_matrix is None or item_features is None:
        print("Cannot train model: No data!")
        return None
    model = LightFM(loss='warp', no_components=10)
    model.fit(interaction_matrix, item_features=item_features, epochs=20)
    return model

# Cold-start fallback
def get_popular_items(top_n=10):
    url = f"{SUPABASE_URL}/rest/v1/farmersordersdetail?select=product_id&order=quantity.desc&limit={top_n}"
    response = requests.get(url, headers=HEADERS)
    if response.status_code != 200:
        print(f"Failed to fetch popular items: {response.text}")
        return []
    data = response.json()
    seen = set()
    unique_popular = [item['product_id'] for item in data if not (item['product_id'] in seen or seen.add(item['product_id']))]
    return unique_popular[:top_n]

# Generate recommendations
def recommend(user_id, model, interaction_matrix, user_id_map, product_id_map, product_ids, top_n=10):
    if model is None:
        return get_popular_items(top_n)
    if user_id not in user_id_map:
        return get_popular_items(top_n)
    user_idx = user_id_map[user_id]
    scores = model.predict(user_idx, np.arange(len(product_ids)))
    top_indices = np.argsort(-scores)
    seen = set()
    unique_top_items = [idx for idx in top_indices if not (product_ids[idx] in seen or seen.add(product_ids[idx]))][:top_n]
    return [product_ids[idx] for idx in unique_top_items]

# Load and train model at startup
interactions_df = fetch_interactions()
products_df = fetch_product_features()
interaction_matrix, item_features, user_id_map, product_id_map, product_ids = preprocess_data(interactions_df, products_df)
model = train_model(interaction_matrix, item_features)

# FastAPI setup
app = FastAPI()

class UserRequest(BaseModel):
    user_id: str

@app.post("/recommend")
async def get_recommendations(request: UserRequest):
    recommendations = recommend(request.user_id, model, interaction_matrix, user_id_map, product_id_map, product_ids)
    return {"product_ids": recommendations}

@app.get("/")
async def root():
    return {"message": "FastAPI is running locally"}