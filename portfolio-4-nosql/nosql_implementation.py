from datetime import datetime
from pymongo import MongoClient


client = MongoClient("mongodb://localhost:27017/")
db = client["paypulse_nosql"]
customers_col = db["customer_wallets"]


def seed_customer_feed():
    customer_doc = {
        "customer_id": 101,
        "full_name": "Amina Bello",
        "email": "amina.bello@example.com",
        "wallets": [
            {
                "wallet_id": 1,
                "account_number": "0123456789",
                "balance": 45000.50,
                "currency": "NGN",
                "status": "ACTIVE",
            }
        ],
        "recent_transactions": [],
        "last_updated": datetime.utcnow(),
    }

    customers_col.replace_one(
        {"customer_id": 101},
        customer_doc,
        upsert=True,
    )


def push_transaction_feed(txn):
    customers_col.update_one(
        {"customer_id": 101},
        {
            "$push": {
                "recent_transactions": {
                    "$each": [txn],
                    "$slice": -10,
                }
            },
            "$set": {"last_updated": datetime.utcnow()},
        },
    )


if __name__ == "__main__":
    seed_customer_feed()

    new_tx = {
        "tx_id": "TX99302",
        "type": "TRANSFER",
        "amount": 1500.00,
        "status": "SUCCESS",
        "timestamp": datetime.utcnow(),
        "counterparty": "Seyi Adeyemi",
    }

    push_transaction_feed(new_tx)

    customer = customers_col.find_one({"customer_id": 101})
    print("Customer feed update succeeded:")
    print({
        "customer_id": customer["customer_id"],
        "full_name": customer["full_name"],
        "recent_transactions_count": len(customer["recent_transactions"]),
    })