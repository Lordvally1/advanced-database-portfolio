import json
import sqlite3
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import urlsplit


ROOT = Path(__file__).resolve().parent
DATABASE = ROOT / "advanced-database-portfolio.db"
FRONTEND = ROOT / "frontend"
HOST = "127.0.0.1"
PORT = 8000


def load_dashboard_data():
    if not DATABASE.is_file():
        raise FileNotFoundError(f"Database not found: {DATABASE}")

    connection = sqlite3.connect(DATABASE)
    connection.row_factory = sqlite3.Row
    try:
        summary = connection.execute(
            """
            SELECT
                (SELECT COUNT(*) FROM Customers) AS customer_count,
                (SELECT COUNT(*) FROM Wallets WHERE status = 'ACTIVE') AS active_wallets,
                (SELECT COALESCE(SUM(balance), 0) FROM Wallets) AS total_balance,
                (SELECT COUNT(*) FROM Transactions) AS transaction_count,
                (SELECT COUNT(*) FROM Transactions WHERE status = 'PENDING') AS pending_count,
                (SELECT COALESCE(SUM(amount), 0)
                 FROM Transactions WHERE status = 'SUCCESS') AS successful_volume
            """
        ).fetchone()

        customers = connection.execute(
            """
            SELECT
                c.customer_id, c.full_name, c.email, c.phone_number,
                w.wallet_id, w.account_number, w.balance, w.currency, w.status,
                (SELECT COUNT(*) FROM Transactions t
                 WHERE t.sender_wallet_id = w.wallet_id
                    OR t.receiver_wallet_id = w.wallet_id) AS transaction_count
            FROM Customers c
            JOIN Wallets w ON w.customer_id = c.customer_id
            ORDER BY c.full_name
            """
        ).fetchall()

        transactions = connection.execute(
            """
            SELECT
                t.transaction_id, t.amount, t.transaction_type, t.status, t.created_at,
                sender.full_name AS sender_name,
                receiver.full_name AS receiver_name,
                sw.account_number AS sender_account,
                rw.account_number AS receiver_account
            FROM Transactions t
            JOIN Wallets sw ON sw.wallet_id = t.sender_wallet_id
            JOIN Customers sender ON sender.customer_id = sw.customer_id
            JOIN Wallets rw ON rw.wallet_id = t.receiver_wallet_id
            JOIN Customers receiver ON receiver.customer_id = rw.customer_id
            ORDER BY t.created_at DESC, t.transaction_id DESC
            """
        ).fetchall()

        spending = connection.execute(
            """
            SELECT c.full_name, COALESCE(SUM(t.amount), 0) AS total
            FROM Customers c
            JOIN Wallets w ON w.customer_id = c.customer_id
            LEFT JOIN Transactions t
                ON t.sender_wallet_id = w.wallet_id
                AND t.status = 'SUCCESS'
                AND t.transaction_type = 'TRANSFER'
            GROUP BY c.customer_id, c.full_name
            ORDER BY total DESC, c.full_name
            """
        ).fetchall()

        audits = connection.execute(
            """
            SELECT a.log_id, a.action_performed, a.ip_address, a.logged_at,
                   a.transaction_id
            FROM AuditLogs a
            ORDER BY a.logged_at DESC, a.log_id DESC
            LIMIT 20
            """
        ).fetchall()

        return {
            "summary": dict(summary),
            "customers": [dict(row) for row in customers],
            "transactions": [dict(row) for row in transactions],
            "spending": [dict(row) for row in spending],
            "audits": [dict(row) for row in audits],
        }
    finally:
        connection.close()


class DashboardHandler(SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=str(FRONTEND), **kwargs)

    def do_GET(self):
        if urlsplit(self.path).path != "/api/dashboard":
            return super().do_GET()

        try:
            payload = json.dumps(load_dashboard_data()).encode("utf-8")
        except (OSError, sqlite3.Error) as error:
            self.send_error(500, f"Unable to load dashboard data: {error}")
            return

        self.send_response(200)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(payload)))
        self.send_header("Cache-Control", "no-store")
        self.end_headers()
        self.wfile.write(payload)


if __name__ == "__main__":
    if not FRONTEND.is_dir():
        raise FileNotFoundError(f"Frontend directory not found: {FRONTEND}")
    server = ThreadingHTTPServer((HOST, PORT), DashboardHandler)
    print(f"PayPulse dashboard is running at http://{HOST}:{PORT}")
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nStopping PayPulse dashboard.")
    finally:
        server.server_close()
