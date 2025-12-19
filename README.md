# 🚀 Serverless API with API Gateway + Lambda + DynamoDB

A fully serverless REST API built on AWS using Terraform.

![AWS](https://img.shields.io/badge/AWS-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)
![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)

---

## 📐 Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          AWS SERVERLESS ARCHITECTURE                        │
│                                                                             │
│    CLIENTS (Browser/curl)                                                   │
│          │                                                                  │
│          ▼                                                                  │
│    ┌───────────────────────────────────────────────────────┐                │
│    │              API GATEWAY (REST API)                   │                │
│    │                                                       │                │
│    │   POST /product      → Create new product             │                │
│    │   GET  /product/{id} → Get product by ID              │                │
│    │   GET  /products     → List all products              │                │
│    └───────────────────────────┬───────────────────────────┘                │
│                                │                                            │
│              ┌─────────────────┼─────────────────┐                          │
│              ▼                 ▼                 ▼                          │
│    ┌──────────────┐  ┌──────────────┐  ┌──────────────┐                     │
│    │   LAMBDA     │  │   LAMBDA     │  │   LAMBDA     │                     │
│    │  AddProduct  │  │  GetProduct  │  │ ListProducts │                     │
│    │  (Python)    │  │  (Python)    │  │  (Python)    │                     │
│    └──────┬───────┘  └──────┬───────┘  └──────┬───────┘                     │
│           │                 │                 │                             │
│           └─────────────────┼─────────────────┘                             │
│                             ▼                                               │
│              ┌─────────────────────────────┐                                │
│              │         DYNAMODB            │                                │
│              │      Products Table         │                                │
│              │                             │                                │
│              │   Primary Key: id (String)  │                                │
│              └─────────────────────────────┘                                │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 🎯 Features

- **Fully Serverless**: No servers to manage, pay only for what you use
- **Auto-scaling**: Handles traffic spikes automatically
- **RESTful API**: Clean endpoints for CRUD operations
- **Infrastructure as Code**: Reproducible with Terraform

---

## 📁 Project Structure

```
aws-serverless-api/
├── main.tf              # All infrastructure resources
├── variables.tf         # Input variable definitions
├── outputs.tf           # Output values (API URLs)
├── terraform.tfvars     # Variable values
├── lambda/
│   ├── add_product.py   # Lambda: Add item to DynamoDB
│   ├── get_product.py   # Lambda: Get item by ID
│   └── list_products.py # Lambda: List all items
├── .gitignore
└── README.md
```

---

## 🛠️ Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 0.14
- [AWS CLI](https://aws.amazon.com/cli/) configured with credentials
- AWS Account

---

## 🚀 Quick Start

### 1. Clone the repository

```bash
git clone https://github.com/ctrivedi-hub/Task_2_serverless-api.git
cd Task_2_serverless-api
```

### 2. Initialize Terraform

```bash
terraform init
```

### 3. Preview the changes

```bash
terraform plan
```

### 4. Deploy

```bash
terraform apply
```

Type `yes` when prompted.

---

## 🧪 Testing the API

After deployment, you'll see the API endpoint URL. Test with these commands:

### Add a Product (POST)

```bash
curl -X POST https://YOUR_API_ID.execute-api.ap-south-1.amazonaws.com/prod/product \
  -H "Content-Type: application/json" \
  -d '{"id":"1","name":"Laptop","price":999.99,"description":"Gaming laptop"}'
```

### Get a Product (GET)

```bash
curl https://YOUR_API_ID.execute-api.ap-south-1.amazonaws.com/prod/product/1
```

### List All Products (GET)

```bash
curl https://YOUR_API_ID.execute-api.ap-south-1.amazonaws.com/prod/products
```

---

## 📊 API Endpoints

| Method | Endpoint | Description | Request Body |
|--------|----------|-------------|--------------|
| POST | `/product` | Create a product | `{"id","name","price","description"}` |
| GET | `/product/{id}` | Get product by ID | - |
| GET | `/products` | List all products | - |

### Sample Request/Response

**POST /product**
```json
// Request
{
  "id": "1",
  "name": "Laptop",
  "price": 999.99,
  "description": "Gaming laptop"
}

// Response (201 Created)
{
  "message": "Product created successfully",
  "product": {
    "id": "1",
    "name": "Laptop",
    "price": 999.99,
    "description": "Gaming laptop",
    "category": "General"
  }
}
```

**GET /product/1**
```json
// Response (200 OK)
{
  "product": {
    "id": "1",
    "name": "Laptop",
    "price": 999.99,
    "description": "Gaming laptop",
    "category": "General"
  }
}
```

---

## ⚙️ Configuration

Edit `terraform.tfvars` to customize:

| Variable | Default | Description |
|----------|---------|-------------|
| `aws_region` | ap-south-1 | AWS region |
| `project_name` | serverless-api | Prefix for resources |
| `dynamodb_table_name` | Products | DynamoDB table name |
| `lambda_runtime` | python3.9 | Lambda runtime |
| `lambda_timeout` | 30 | Timeout in seconds |
| `lambda_memory` | 128 | Memory in MB |

---

## 🧹 Cleanup

**Important**: Delete resources to avoid charges!

```bash
terraform destroy
```

---

## 💰 Cost Estimation

| Resource | Free Tier |
|----------|-----------|
| Lambda | 1M requests/month free |
| DynamoDB | 25 GB storage, 25 RCU/WCU free |
| API Gateway | 1M API calls/month free |

> This project stays within Free Tier limits for normal usage.

---

## 📚 Key Concepts Learned

### Lambda
- Serverless compute - runs code without managing servers
- Pay per invocation (first 1M free/month)
- Supports Python, Node.js, Java, Go, etc.

### DynamoDB
- Fully managed NoSQL database
- Key-value and document data models
- Scales automatically

### API Gateway
- Managed service for creating REST APIs
- Handles routing, security, throttling
- Integrates directly with Lambda

### IAM
- Identity and Access Management
- Lambda needs IAM role to access DynamoDB
- Principle of least privilege

---

## 🤝 Contributing

Feel free to fork and submit pull requests!

---

## 📄 License

MIT License

---

**⭐ Star this repo if you found it helpful!**

