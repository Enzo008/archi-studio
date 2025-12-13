# 03-Database - SQL Server Database Layer

## 🎯 **Overview**

Esta carpeta contiene toda la lógica de base de datos del proyecto, diseñada con un enfoque **Performance-First** para manejar grandes volúmenes de datos con técnicas avanzadas de optimización de SQL Server.

## 🗂️ **Folder Structure**

```
03-Database/
├── Tables/                 # Table creation and modification scripts
│   ├── CREATE_*.sql       # Table creation scripts
│   ├── ALTER_*.sql        # Table modification scripts
│   └── INDEX_*.sql        # Index creation scripts
├── TableTypes/            # User-defined table types
├── StoredProcedures/      # All stored procedures
│   ├── SP_INSERTAR_*.sql  # Insert procedures
│   ├── SP_ACTUALIZAR_*.sql # Update procedures
│   ├── SP_CONSULTAR_*.sql  # Select procedures
│   ├── SP_ELIMINAR_*.sql   # Delete procedures
│   ├── SP_LISTAR_*.sql     # List/search procedures
│   └── SP_OBTENER_*.sql    # Utility procedures
├── Functions/             # User-defined functions
│   ├── FN_*.sql          # Scalar functions
│   └── FN_TABLE_*.sql    # Table-valued functions
├── Views/                 # Database views
├── Scripts/               # Utility and maintenance scripts
│   ├── MIGRATION_*.sql   # Data migration scripts
│   ├── MAINTENANCE_*.sql # Maintenance procedures
│   └── TEMPLATE_*.sql    # Code templates
└── Documentation/         # Database documentation
    ├── SCHEMA_*.md       # Schema documentation
    └── PROCEDURES_*.md   # Procedure documentation
```

## 🚀 **Key Features**

### **Performance Optimization**
- **Temporary Tables with Indexes**: Complex filtering using indexed temp tables
- **Precalculated Aggregations**: Avoiding expensive subqueries
- **Efficient Pagination**: Using OFFSET/FETCH for large datasets
- **Memory Management**: Explicit cleanup of temporary resources

### **Advanced Timezone Auditing**
- **Local Time Storage**: Dates stored in user's timezone
- **Friendly Names**: Human-readable timezone names (e.g., "America/Lima")
- **Complete Context**: Every record knows when, who, and from where it was created
- **Global Support**: Multi-region application ready

### **Professional Standards**
- **Consistent Naming**: Clear prefixes and conventions
- **Comprehensive Logging**: Full audit trail with SP_REGISTER_LOG
- **Error Handling**: Robust TRY/CATCH patterns
- **Security**: Granular access control with TV_USUARIO_ACCESO

## 📋 **Quick Start**

### **Creating New Procedures**
1. Use appropriate template from `Scripts/TEMPLATE_*.sql`
2. Follow naming conventions: `SP_[ACTION]_[ENTITY]`
3. Include timezone handling for audit fields
4. Implement proper error handling and logging

### **Example: Creating SP_INSERTAR_PRODUCTO**
```sql
-- Copy from Scripts/TEMPLATE_SP_INSERTAR.sql
-- Replace [ENTITY] with PRODUCTO
-- Replace [FIELD1], [FIELD2] with actual fields
-- Customize validation logic
```

## 🌍 **Timezone System**

### **How It Works**
```sql
-- Get user timezone info
EXEC SP_OBTENER_INFO_LOCALIZACION_USUARIO 
    @P_USEYEA_U, @P_USECOD_U,
    @P_TIMEZONE_OFFSET = @V_TIMEZONE_OFFSET OUTPUT,
    @P_TIMEZONE_NAME = @V_TIMEZONE_NAME OUTPUT;

-- Store with timezone context
FECING = SWITCHOFFSET(SYSDATETIME(), @V_TIMEZONE_OFFSET),
FECINGTIM = @V_TIMEZONE_NAME  -- "America/Lima" for user display
```

### **Benefits**
- ✅ Users see dates in their local timezone
- ✅ UI shows friendly names like "Hora Perú"
- ✅ Complete audit trail with geographic context
- ✅ Global application support

## 📊 **Performance Examples**

### **SP_LISTAR_MONITOREO - Advanced Optimization**
This procedure demonstrates enterprise-level optimization techniques:

```sql
-- 1. Centralized filtering with temp tables
CREATE TABLE #FiltroSubproyecto (SUBPROANO CHAR(4), SUBPROCOD CHAR(6));

-- 2. Strategic indexing
CREATE NONCLUSTERED INDEX IX_FilteredMetas_Meta ON #FilteredMetas(METANO, METCOD);

-- 3. Precalculated aggregations
CREATE TABLE #Aggregations (EntityID INT, TotalCount INT);

-- 4. Efficient final query with JOINs
SELECT ... FROM #FilteredData FD
LEFT JOIN #Aggregations AGG ON FD.ID = AGG.EntityID
```

**Result**: Fast response times even with millions of records and complex calculations.

## 🔧 **Development Guidelines**

### **Naming Conventions**
- **Tables**: `TM_` (Master), `TB_` (Base), `TV_` (Views), `TH_` (Historical)
- **Procedures**: `SP_INSERTAR_`, `SP_ACTUALIZAR_`, `SP_CONSULTAR_`, `SP_LISTAR_`
- **Parameters**: `@P_` (Input), `@V_` (Variables), `_OUTPUT` (Output)

### **Required Standards**
- [ ] Use templates for consistency
- [ ] Include timezone handling
- [ ] Implement proper error handling
- [ ] Add comprehensive logging
- [ ] Clean up temporary resources
- [ ] Validate all input parameters
- [ ] Follow security patterns

## 📚 **Documentation**

### **Essential Reading**
- [`Documentation/SCHEMA_OVERVIEW.md`](Documentation/SCHEMA_OVERVIEW.md) - Complete database architecture
- [`Documentation/PROCEDURES_GUIDE.md`](Documentation/PROCEDURES_GUIDE.md) - SP development guide

### **Templates Available**
- [`Scripts/TEMPLATE_SP_INSERTAR.sql`](Scripts/TEMPLATE_SP_INSERTAR.sql) - Insert operations
- [`Scripts/TEMPLATE_SP_ACTUALIZAR.sql`](Scripts/TEMPLATE_SP_ACTUALIZAR.sql) - Update operations
- [`Scripts/TEMPLATE_SP_LISTAR_OPTIMIZED.sql`](Scripts/TEMPLATE_SP_LISTAR_OPTIMIZED.sql) - Optimized listings
- [`Scripts/TEMPLATE_SP_CONSULTAR.sql`](Scripts/TEMPLATE_SP_CONSULTAR.sql) - Single record queries

## 🎯 **Best Practices Summary**

### **Performance**
1. **Use temporary tables** for complex filtering
2. **Create indexes** on temp tables for JOINs
3. **Precalculate aggregations** to avoid subqueries
4. **Implement pagination** for large result sets
5. **Clean up resources** explicitly

### **Security**
1. **Validate all parameters** before processing
2. **Check user permissions** via TV_USUARIO_ACCESO
3. **Log all operations** with full context
4. **Use parameterized queries** to prevent injection

### **Maintainability**
1. **Follow naming conventions** consistently
2. **Use templates** for new procedures
3. **Document complex logic** in comments
4. **Include modification history** in headers
5. **Test with realistic data volumes**

## 🚀 **Getting Started**

1. **Review Documentation**: Start with `SCHEMA_OVERVIEW.md`
2. **Understand Templates**: Check available templates in `Scripts/`
3. **Follow Examples**: Study existing procedures like `SP_LISTAR_MONITOREO`
4. **Use Patterns**: Apply established patterns for consistency
5. **Test Performance**: Always test with large datasets

This database layer is designed to be **professional, scalable, and maintainable**, following enterprise-level best practices for high-performance SQL Server applications.