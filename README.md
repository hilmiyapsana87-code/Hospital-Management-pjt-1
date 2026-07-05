# Hospital Management Analytics 🏥📊

An end-to-end data analytics project analyzing hospital operations — patient demographics, doctor performance, appointment trends, treatment outcomes, and revenue — using **SQL Server** for data modeling and **Power BI** for interactive visualization.

## 📌 Project Overview

Hospitals generate large volumes of operational data every day, but turning that data into decisions is hard without the right structure. This project simulates a real-world hospital management system and builds a complete analytics pipeline on top of it — from raw relational data to a polished, decision-ready dashboard.

The goal: help hospital administrators answer questions like —
- Which departments generate the most revenue?
- How are doctors performing in terms of patient load and outcomes?
- What do patient demographics and appointment patterns look like?
- Where are the bottlenecks in the treatment-to-billing pipeline?

## 🗂️ Dataset Structure

The database consists of 5 interconnected tables:

| Table | Description |
|---|---|
| `patients` | Patient demographics and registration details |
| `doctors` | Doctor profiles, specializations, and department mapping |
| `appointments` | Appointment scheduling, status, and doctor-patient links |
| `treatments` | Treatment records, diagnoses, and procedures |
| `billing` | Revenue, payment status, and billing details per treatment |

## 🛠️ Tech Stack

- **SQL Server (SSMS)** — data modeling, cleaning, and querying
- **Power BI** — dashboard design and DAX-based insights
- **DAX** — custom measures for KPIs and trend analysis

## 🔍 SQL Work

- Multi-table JOINs across patients, doctors, appointments, treatments, and billing
- CTEs and window functions for ranking and running calculations
- Stored procedures (e.g., `sp_DeptRevenueReport`) for repeatable reporting
- CASE WHEN, NULLIF, DATEDIFF for data cleaning and derived metrics
- Views for simplified, reusable reporting layers

## 📊 Power BI Dashboard

The dashboard covers three core areas:

1. **Patient Demographics** — age distribution, gender split, geographic trends
2. **Doctor Performance** — patient load, specialization breakdown, appointment completion rates
3. **Revenue Insights** — department-wise revenue, billing status, payment trends

Key features:
- Interactive slicers and drill-through navigation
- KPI cards for at-a-glance metrics
- Custom DAX measures for performance tracking

## 📷 Dashboard Preview

<img width="1366" height="768" alt="Screenshot 2026-05-02 153537" src="https://github.com/user-attachments/assets/cf7c5c3c-1a68-449c-b545-7bdbe63a7499" />

<img width="1366" height="768" alt="Screenshot 2026-05-02 153752" src="https://github.com/user-attachments/assets/9188ac6b-0ed6-4e10-aaf4-51d95c1ce7ea" />


<img width="1366" height="768" alt="Screenshot 2026-05-02 153812" src="https://github.com/user-attachments/assets/93ab3df5-d2a4-447a-88ed-fcc771a21e01" />


## 🎯 What This Project Demonstrates

- Relational database design and normalization
- Advanced SQL querying and stored procedure development
- Business-focused dashboard design in Power BI
- Translating raw operational data into actionable healthcare insights

---
*This project uses a publicly available hospital dataset for educational and portfolio purposes.*
****
