Multi-Tenant SaaS Relational Database Schema (3NF Compliant)

Overview

This repository contains a 3rd Normal Form (3NF) compliant relational database implementation for a multi-tenant SaaS task and project management platform built on PostgreSQL 16.

The architecture ensures tenant-level data isolation, enforces strict referential integrity with cascading foreign key constraints, and supports 1:1, 1:N, and N:M relationships across core domain entities.

Entity-Relationship Architecture

The schema consists of 6 interconnected tables using UUID primary keys for global uniqueness and scalable multi-tenant partitioning:

tenants (Core Multi-Tenant Entity)

Represents isolated customer organizations.

tenant_profiles (1:1 Relationship with tenants)

Extended configuration and metadata for a tenant.

users (1:N Relationship with tenants)

Platform users scoped strictly to a tenant (tenant_id).

projects (1:N Relationship with tenants)

Project workspaces scoped to a tenant.

tasks (1:N with projects, optional 1:N with users)

Task items scoped to a project and assigned to a user within the same tenant context.

tags (1:N with tenants) & task_tags (N:M Junction Table)

Tenant-scoped tags linked to tasks via a many-to-many junction table.

Database Constraints & Integrity Rules

Primary Keys: Every table uses auto-generated UUID primary keys (gen_random_uuid()).

Foreign Keys: Enforces strict cascading rules (ON DELETE CASCADE for dependent entities, ON DELETE SET NULL for user assignments).

Check Constraints: CHECK (status IN ('TODO', 'IN_PROGRESS', 'COMPLETED', 'BLOCKED')) on tasks to validate lifecycle states.

Unique Constraints: Composite unique constraint (tenant_id, email) ensures email uniqueness per tenant, allowing multi-tenant registration.

3NF Compliance Proof

First Normal Form (1NF):

All columns contain scalar, atomic values.

Repeating groups and multi-valued attributes are eliminated. Every table has a primary key.

Second Normal Form (2NF):

Complies with 1NF and all non-key columns fully depend on the primary key. In task_tags (composite PK task_id, tag_id), no partial dependencies exist.

Third Normal Form (3NF):

Complies with 2NF and no transitive functional dependencies exist ($X \rightarrow Y$ where $Y \rightarrow Z$). Non-key attributes depend strictly on their table's primary key.

Execution Instructions

Connect to your local PostgreSQL instance (via pgAdmin or psql).

Run schema.sql to initialize tables and relationships.

Run seed_data.sql to populate sample multi-tenant test data.

Execute the verification query below to validate all relationships.

Verification Query

SELECT 
    t.name AS tenant_name,
    tp.domain,
    u.full_name AS assigned_user,
    p.name AS project_name,
    ts.title AS task_title,
    ts.status AS task_status,
    tg.name AS tag_name
FROM tenants t
JOIN tenant_profiles tp ON t.id = tp.tenant_id
JOIN users u ON t.id = u.tenant_id
JOIN projects p ON t.id = p.tenant_id
JOIN tasks ts ON p.id = ts.project_id
LEFT JOIN task_tags tt ON ts.id = tt.task_id
LEFT JOIN tags tg ON tt.tag_id = tg.id;
