# Multi-Tenant SaaS Relational Database Schema (3NF Compliant)

## Overview
This repository contains a 3rd Normal Form (3NF) compliant relational database implementation for a multi-tenant SaaS task and project management platform built on PostgreSQL 16.

The architecture ensures tenant-level data isolation, enforces strict referential integrity with cascading foreign key constraints, and supports 1:1, 1:N, and N:M relationships across core domain entities.

---

## Entity-Relationship Architecture

The schema consists of 6 interconnected tables using `UUID` primary keys for global uniqueness and scalable multi-tenant partitioning:

1. **`tenants`** (Core Multi-Tenant Entity)
   * Represents isolated customer organizations.
2. **`users`** (Scoped to Tenant)
   * System users associated with a specific tenant via `tenant_id`. Enforces unique email per tenant via composite constraint `(tenant_id, email)`.
3. **`projects`** (Scoped to Tenant)
   * High-level project containers belonging to a tenant.
4. **`tasks`** (Scoped to Project & User)
   * Action items linked to a parent project and optionally assigned to a user within the same tenant context.
5. **`tags`** (Scoped to Tenant)
   * Custom tags created per tenant for categorization. Enforces unique tag name per tenant via `(tenant_id, name)`.
6. **`task_tags`** (N:M Junction Table)
   * Links tasks and tags directly with a composite primary key `(task_id, tag_id)`.

---

## 3NF Normalization Breakdown

* **1st Normal Form (1NF)**: All attributes contain atomic values (e.g., standard data types, no multi-valued arrays or comma-separated lists). Each table has a defined primary key (`id` or composite PK).
* **2nd Normal Form (2NF)**: All non-key attributes are fully functionally dependent on the entire primary key. In the `task_tags` junction table, no non-key attributes exist, eliminating partial dependencies.
* **3rd Normal Form (3NF)**: Transitive dependencies are removed. Foreign keys (`tenant_id`, `project_id`, `assigned_user_id`) directly reference their parent tables rather than deriving attributes transitively.

---

## SQL Source Files

* **`schema.sql`**: Full DDL script defining table structures, primary keys, foreign keys with `ON DELETE CASCADE`/`SET NULL` rules, and unique constraints.
* **`seed_data.sql`**: Data insertion script utilizing Common Table Expressions (CTEs) to generate UUIDs and insert multi-tenant sample data across all tables.

---

## Verification Query

To verify referential integrity and multi-tenant linkage across all 6 tables, run:

```sql
SELECT 
    t.name AS tenant_name,
    u.full_name AS assigned_user,
    p.name AS project_name,
    ts.title AS task_title,
    ts.status AS task_status,
    tg.name AS tag_name
FROM tenants t
JOIN users u ON t.id = u.tenant_id
JOIN projects p ON t.id = p.tenant_id
JOIN tasks ts ON p.id = ts.project_id
LEFT JOIN task_tags tt ON ts.id = tt.task_id
LEFT JOIN tags tg ON tt.tag_id = tg.id;
