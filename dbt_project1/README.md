
-----------------------------------------------------------------
# Superstore Automated ELT Pipeline

An end-to-end ELT (Extract, Load, Transform) data pipeline built to ingest, transform, validate, and orchestrate Superstore data using Python, DuckDB, dbt, Apache Airflow, and Docker.

The project demonstrates a production-style data workflow with layered data modeling, automated data quality testing, dependency management, and workflow orchestration.

---

## Architecture & Workflow

The pipeline follows an automated ELT architecture:

                    ┌─────────────────┐
                    │  Superstore CSV │
                    │   Raw Dataset   │
                    └────────┬────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │     Python      │
                    │  Data Ingestion │
                    └────────┬────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │      DuckDB     │
                    │       ODS       │
                    └────────┬────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │   dbt Staging   │
                    │  stg_* models   │
                    └────────┬────────┘
                             │
                             ▼
              ┌─────────────────────────────┐
              │        dbt Marts            │
              │                             │
              │  dim_customers              │
              │  dim_payments               │
              │  fct_orders                 │
              └──────────────┬──────────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │   dbt Tests     │
                    │ Data Validation │
                    └────────┬────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │ Apache Airflow  │
                    │  Orchestration  │
                    └─────────────────┘

### 1. Extract & Load — ODS Layer

Python is used to ingest the raw Superstore data into **DuckDB**.

The data is first loaded into the **ODS (Operational Data Store)** layer, preserving the raw operational structure before transformation.

### 2. Transform — dbt Staging Layer

The ODS data is transformed using **dbt staging models**.

The staging layer is responsible for preparing the source data for analytical modeling while keeping the transformations modular and easy to maintain.

Example staging models:

* `stg_customers`
* `stg_orders`
* `stg_payments`

### 3. Transform — Analytical Data Marts

dbt transforms the staging data into an analytical **Star Schema** consisting of fact and dimension tables.

```text
                 dim_customers
                       │
                       │
                       ▼
stg_orders ───────► fct_orders ◄────── stg_payments
```

The main models are:

* `dim_customers`
* `dim_payments`
* `fct_orders`

#### Fact Table Grain

The grain of `fct_orders` is:

> **One row per order line.**

Therefore:

* `row_id` is expected to be **unique and not null**.
* `order_id` is **not unique**, because one order can contain multiple order lines.
* `customer_id` and `order_id` are expected to be **not null**.

This grain definition is reflected directly in the dbt data quality tests.

### 4. Data Quality

Automated dbt tests validate the transformed data before the pipeline is considered successful.

Current tests include:

* `NOT NULL`
* `UNIQUE`
* Primary business-key validation according to the model grain

For example:

```text
fct_orders
│
├── row_id
│   ├── NOT NULL
│   └── UNIQUE
│
├── customer_id
│   └── NOT NULL
│
└── order_id
    └── NOT NULL
```

### 5. Orchestration — Apache Airflow

**Apache Airflow** orchestrates the complete workflow through a DAG.

Airflow manages:

* Task dependencies
* Data ingestion
* dbt transformations
* Data quality validation
* Task execution and failure handling

The dbt commands are executed through Airflow `BashOperator` tasks inside the Docker environment.

---

## 🛠️ Tech Stack

| Technology         | Purpose                                      |
| ------------------ | -------------------------------------------- |
| **Python**         | Data ingestion and pipeline scripting        |
| **DuckDB**         | Analytical database engine                   |
| **dbt**            | Data transformation and data quality testing |
| **Apache Airflow** | Workflow orchestration                       |
| **Docker**         | Containerized execution environment          |
| **Docker Compose** | Multi-container infrastructure               |
| **SQL**            | Data transformation and analytical modeling  |

---

## 📂 Project Structure

```text
Superstore-ELT-pipeline/
│
├── dags/
│   └── superstore_pipeline.py
│       # Airflow DAG definition
│
├── dbt_project1/
│   ├── models/
│   │   ├── staging/
│   │   │   ├── stg_customers.sql
│   │   │   ├── stg_orders.sql
│   │   │   ├── stg_payments.sql
│   │   │   ├── schema.yml
│   │   │   └── sources.yml
│   │   │
│   │   └── marts/
│   │       ├── dim_customers.sql
│   │       ├── dim_payments.sql
│   │       ├── fct_orders.sql
│   │       └── schema.yml
│   │
│   ├── dbt_project.yml
│   └── profiles.yml
│
├── scripts/
│   └── load_to_ods.py
│       # Python ingestion script
│
├── docker-compose.yaml
│   # Airflow and supporting services
│
└── README.md
```

---

## 🔄 Pipeline Execution Flow

The complete workflow can be summarized as:


Raw Superstore Data
        │
        ▼
Python Ingestion
        │
        ▼
DuckDB ODS
        │
        ▼
dbt Staging
        │
        ▼
dbt Data Marts
        │
        ▼
Data Quality Tests
        │
        ▼
Pipeline Success / Failure


Airflow controls the execution order and ensures that downstream tasks depend on the successful completion of upstream tasks.
![alt text](<Screenshot 2026-10-03 221340.png>)

---

## 🚀 Getting Started

### Prerequisites

Make sure the following are installed:

* Docker Desktop
* Git

---


### 1. Clone the Repository

```bash
git clone https://github.com/SAMA-88/Superstore-ELT-pipeline.git

cd Superstore-ELT-pipeline


---

### 2. Start the Infrastructure

Run:

```bash
docker compose up -d
```

Check the running containers:

```bash
docker ps
```

---

### 3. Access Airflow

Open the Airflow Web UI:

```text
http://localhost:8081
```

Find the DAG:

```text
superstore_elt_pipeline
```

Trigger the DAG manually to start the complete pipeline.

---

## Running dbt Manually

dbt commands can also be executed inside the Airflow scheduler container.

Enter the container:

```bash
docker exec -it superstore-elt-pipeline-airflow-scheduler-1 bash
```

Navigate to the dbt project:

```bash
cd /opt/airflow/dbt_project1
```

### Run dbt Models

```bash
dbt run --profiles-dir .
```

### Run Data Quality Tests

```bash
dbt test --profiles-dir .
```

### Run Both

```bash
dbt build --profiles-dir .
```

---

## Data Quality Strategy

The project follows a simple validation strategy where data quality checks are aligned with the **data model and table grain**.

For the `fct_orders` model:

```text
Grain:
1 row = 1 order line

Unique Key:
row_id

Required Fields:
row_id
customer_id
order_id
```

This prevents incorrect assumptions such as treating `order_id` as unique when one order can legitimately contain multiple order lines.

---

## Key Engineering Concepts Demonstrated

This project demonstrates practical implementation of:

* ELT architecture
* ODS and staging layers
* Dimensional modeling
* Star schema
* Fact and dimension tables
* Table grain definition
* SQL transformations
* dbt models
* dbt data quality tests
* Airflow DAG orchestration
* Task dependencies
* Dockerized data pipelines
* DuckDB analytical processing
* Automated pipeline validation
* Failure detection through data quality checks

---

## 🎯 Project Goal

The goal of this project is to demonstrate how a raw operational dataset can be transformed into a structured analytical data platform using modern data engineering tools.

The pipeline combines **ingestion, transformation, dimensional modeling, data quality validation, and orchestration** into one automated workflow.


