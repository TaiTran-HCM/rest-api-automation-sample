from flask import Flask, request, jsonify
import datetime, jwt

app = Flask(__name__)
SECRET = "mysecretkey"

# Fake database
USERS = [
    {"id": 1, "username": "admin", "password": "123", "role": "admin"},
    {"id": 2, "username": "user1", "password": "abc", "role": "user"}
]

PRODUCTS = [
    {"id": 1, "name": "Book", "price": 10},
    {"id": 2, "name": "Pen", "price": 2}
]

# Login endpoint
@app.route("/login", methods=["POST"])
def login():
    data = request.json
    user = next((u for u in USERS if u["username"] == data.get("username") and u["password"] == data.get("password")), None)
    if not user:
        return jsonify({"error": "Invalid credentials"}), 401

    token = jwt.encode(
        {"user": user["username"], "role": user["role"], "exp": datetime.datetime.utcnow() + datetime.timedelta(hours=1)},
        SECRET,
        algorithm="HS256"
    )
    return jsonify({"token": f"Bearer {token}", "username": user["username"], "role": user["role"]})

# Protected endpoint
@app.route("/products", methods=["GET"])
def get_products():
    auth_header = request.headers.get("Authorization", "")
    if not auth_header.startswith("Bearer "):
        return jsonify({"error": "Missing token"}), 401
    token = auth_header.split(" ")[1]
    try:
        jwt.decode(token, SECRET, algorithms=["HS256"])
    except jwt.ExpiredSignatureError:
        return jsonify({"error": "Token expired"}), 403
    except jwt.InvalidTokenError:
        return jsonify({"error": "Invalid token"}), 403
    return jsonify(PRODUCTS)

@app.route("/products", methods=["POST"])
def create_product():
    # Check Authorization header
    auth_header = request.headers.get("Authorization", "")
    if not auth_header.startswith("Bearer "):
        return jsonify({"error": "Missing token"}), 401

    token = auth_header.split(" ")[1]
    try:
        decoded = jwt.decode(token, SECRET, algorithms=["HS256"])
    except jwt.ExpiredSignatureError:
        return jsonify({"error": "Token expired"}), 403
    except jwt.InvalidTokenError:
        return jsonify({"error": "Invalid token"}), 403

    # ✅ Kiểm tra role
    if decoded.get("role") != "admin":
        return jsonify({"error": "Admin role required"}), 403

    # Parse request body
    data = request.get_json()
    if not data or "name" not in data or "price" not in data:
        return jsonify({"error": "Missing required fields"}), 400

    new_product = {
        "id": len(PRODUCTS) + 1,
        "name": data["name"],
        "price": data["price"],
    }

    return jsonify(new_product), 201

# Get single product
@app.route("/products/<int:product_id>", methods=["GET"])
def get_product(product_id):
    auth_header = request.headers.get("Authorization", "")
    if not auth_header.startswith("Bearer "):
        return jsonify({"error": "Missing token"}), 401

    token = auth_header.split(" ")[1]
    try:
        jwt.decode(token, SECRET, algorithms=["HS256"])
    except jwt.ExpiredSignatureError:
        return jsonify({"error": "Token expired"}), 403
    except jwt.InvalidTokenError:
        return jsonify({"error": "Invalid token"}), 403

    product = next((p for p in PRODUCTS if p["id"] == product_id), None)
    if not product:
        return jsonify({"error": "Product not found"}), 404
    return jsonify(product)


# Update product (admin only)
@app.route("/products/<int:product_id>", methods=["PUT"])
def update_product(product_id):
    auth_header = request.headers.get("Authorization", "")
    if not auth_header.startswith("Bearer "):
        return jsonify({"error": "Missing token"}), 401

    token = auth_header.split(" ")[1]
    try:
        decoded = jwt.decode(token, SECRET, algorithms=["HS256"])
    except jwt.ExpiredSignatureError:
        return jsonify({"error": "Token expired"}), 403
    except jwt.InvalidTokenError:
        return jsonify({"error": "Invalid token"}), 403

    if decoded.get("role") != "admin":
        return jsonify({"error": "Admin role required"}), 403

    product = next((p.copy() for p in PRODUCTS if p["id"] == product_id), None)
    if not product:
        return jsonify({"error": "Product not found"}), 404

    data = request.get_json()
    if "name" in data:
        product["name"] = data["name"]
    if "price" in data:
        product["price"] = data["price"]
    return jsonify(product)


# Delete product (admin only)
@app.route("/products/<int:product_id>", methods=["DELETE"])
def delete_product(product_id):
    auth_header = request.headers.get("Authorization", "")
    if not auth_header.startswith("Bearer "):
        return jsonify({"error": "Missing token"}), 401

    token = auth_header.split(" ")[1]
    try:
        decoded = jwt.decode(token, SECRET, algorithms=["HS256"])
    except jwt.ExpiredSignatureError:
        return jsonify({"error": "Token expired"}), 403
    except jwt.InvalidTokenError:
        return jsonify({"error": "Invalid token"}), 403

    if decoded.get("role") != "admin":
        return jsonify({"error": "Admin role required"}), 403

    product = next((p for p in PRODUCTS if p["id"] == product_id), None)
    if not product:
        return jsonify({"error": "Product not found"}), 404

    return jsonify({"message": "Product deleted"})


# Get all users (admin only)
@app.route("/users", methods=["GET"])
def get_users():
    auth_header = request.headers.get("Authorization", "")
    if not auth_header.startswith("Bearer "):
        return jsonify({"error": "Missing token"}), 401

    token = auth_header.split(" ")[1]
    try:
        decoded = jwt.decode(token, SECRET, algorithms=["HS256"])
    except jwt.ExpiredSignatureError:
        return jsonify({"error": "Token expired"}), 403
    except jwt.InvalidTokenError:
        return jsonify({"error": "Invalid token"}), 403

    if decoded.get("role") != "admin":
        return jsonify({"error": "Admin role required"}), 403

    return jsonify(USERS)


# Health check (no auth required)
@app.route("/health", methods=["GET"])
def health():
    return jsonify({"status": "ok", "time": datetime.datetime.utcnow().isoformat()})


if __name__ == "__main__":
    app.run(port=5000)
