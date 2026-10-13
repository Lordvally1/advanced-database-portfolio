from pymongo import MongoClient
import datetime

client = MongoClient("mongodb://localhost:27017/")
db = client["paypulse_nosql"]
customers_col = db["customer_wallets"]

# Insert Customer Document
customer_doc = {
    "customer_id": 101,
    "full_name": "Amina Bello",
    "email": "amina.bello@example.com",
    "wallets": [{"wallet_id": 1, "account_number": "0123456789", "balance": 45000.50}],
    "recent_transactions": []
}
customers_col.insert_one(customer_doc)

# Atomic Transaction Feed Push
new_tx = {
    "tx_id": "TX99302",
    "type": "TRANSFER",
    "amount": 1500.00,
    "status": "SUCCESS",
    "timestamp": datetime.datetime.utcnow()
}

customers_col.update_one(
    {"customer_id": 101},
    {"$push": {"recent_transactions": {"$each": [new_tx], "$slice": -10}}}
)

print("Document updated successfully.")
