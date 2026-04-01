---
name: postgis-to-qgis
description: Use this skill when the user wants to load PostGIS tables into QGIS, bridge PostGIS and QGIS, visualize database layers, or says "load postgis layer", "show table in qgis", "postgis to qgis".
version: 1.0.0
---

# PostGIS to QGIS Bridge

Load PostGIS database tables as layers in QGIS via MCP.

## Overview

This skill helps you:
1. List available tables in PostGIS
2. Generate the correct QGIS connection URI
3. Load tables as vector layers in QGIS

## Prerequisites

- PostGIS MCP server running and connected
- QGIS MCP server running (QGIS open with plugin started)
- Both servers visible in `/mcp`

## Step 1: List PostGIS Tables

Use the PostGIS MCP to query available tables:

```sql
SELECT table_schema, table_name, geometry_column
FROM geometry_columns
ORDER BY table_schema, table_name;
```

Or list all tables:

```sql
SELECT schemaname, tablename
FROM pg_tables
WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
ORDER BY schemaname, tablename;
```

## Step 2: Generate QGIS Connection URI

QGIS uses a specific URI format for PostgreSQL/PostGIS layers:

```
dbname='DATABASE' host='HOST' port='PORT' user='USER' password='PASSWORD' table="SCHEMA"."TABLE" (GEOM_COLUMN)
```

### Example URIs

Basic table:
```
dbname='gis' host='127.0.0.1' port='5433' user='docker' password='<password>' table="public"."parcels" (geom)
```

With SQL filter:
```
dbname='gis' host='127.0.0.1' port='5433' user='docker' password='<password>' table="public"."parcels" (geom) sql=status='active'
```

Specific primary key:
```
dbname='gis' host='127.0.0.1' port='5433' user='docker' password='<password>' key='id' table="public"."parcels" (geom)
```

## Step 3: Load Layer in QGIS

Use the QGIS MCP `add_vector_layer` tool:

```python
add_vector_layer(
    path="dbname='gis' host='127.0.0.1' port='5433' user='docker' password='<password>' table=\"public\".\"my_table\" (geom)",
    provider="postgres",
    name="My PostGIS Layer"
)
```

**Important**: Use `provider="postgres"` (not the default "ogr").

## Connection Parameters Reference

| Parameter | Description | Example |
|-----------|-------------|---------|
| `dbname` | Database name | `'gis'` |
| `host` | Server hostname | `'127.0.0.1'` |
| `port` | Server port | `'5433'` |
| `user` | Username | `'docker'` |
| `password` | Password | `'<password>'` |
| `table` | Schema and table | `"public"."parcels"` |
| `(geom)` | Geometry column | `(geom)`, `(the_geom)`, `(wkb_geometry)` |
| `key` | Primary key column | `'id'` |
| `sql` | WHERE clause filter | `status='active'` |
| `srid` | Force SRID | `4326` |

## Workflow Example

```
User: "Load the parcels table from PostGIS into QGIS"

1. Query PostGIS for table info:
   SELECT * FROM geometry_columns WHERE f_table_name = 'parcels';

2. Get: schema=public, geom_column=geom, srid=4326

3. Build URI:
   dbname='gis' host='127.0.0.1' port='5433' user='docker' password='<password>' table="public"."parcels" (geom)

4. Call QGIS MCP:
   add_vector_layer(path=<uri>, provider="postgres", name="Parcels")

5. Optionally zoom:
   zoom_to_layer(layer_id=<returned_id>)
```

## Troubleshooting

### "Layer is not valid"
- Check geometry column name matches exactly
- Verify table exists and has geometry
- Ensure credentials are correct

### "Could not connect to database"
- Verify tunnel is active (port 5433 listening)
- Test connection with psql first
- Check firewall/network settings

### Missing Features
- Table might be empty
- SQL filter might be too restrictive
- Check `get_layer_features` output
