/**
 * Utilidad para exportar datos a PDF usando @react-pdf/renderer
 * Genera PDFs profesionales con diseño ArchiStudio
 */

import {
  Document,
  Page,
  Text,
  View,
  StyleSheet,
  pdf,
} from '@react-pdf/renderer';
import { saveAs } from 'file-saver';
import type { Project, Budget, Client } from '@/types';

// Estilos del documento
const styles = StyleSheet.create({
  page: {
    padding: 40,
    fontSize: 10,
    fontFamily: 'Helvetica',
  },
  header: {
    marginBottom: 20,
    borderBottom: '2 solid #c65d3b',
    paddingBottom: 10,
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#1e293b',
  },
  subtitle: {
    fontSize: 12,
    color: '#64748b',
    marginTop: 4,
  },
  date: {
    fontSize: 9,
    color: '#94a3b8',
    marginTop: 8,
  },
  table: {
    marginTop: 10,
  },
  tableHeader: {
    flexDirection: 'row',
    backgroundColor: '#f1f5f9',
    borderBottom: '1 solid #e2e8f0',
    paddingVertical: 8,
    paddingHorizontal: 4,
  },
  tableRow: {
    flexDirection: 'row',
    borderBottom: '1 solid #f1f5f9',
    paddingVertical: 8,
    paddingHorizontal: 4,
  },
  tableRowAlt: {
    flexDirection: 'row',
    borderBottom: '1 solid #f1f5f9',
    paddingVertical: 8,
    paddingHorizontal: 4,
    backgroundColor: '#fafafa',
  },
  tableCell: {
    flex: 1,
    fontSize: 9,
  },
  tableCellHeader: {
    flex: 1,
    fontSize: 9,
    fontWeight: 'bold',
    color: '#475569',
  },
  footer: {
    position: 'absolute',
    bottom: 30,
    left: 40,
    right: 40,
    textAlign: 'center',
    fontSize: 8,
    color: '#94a3b8',
    borderTop: '1 solid #e2e8f0',
    paddingTop: 10,
  },
  summary: {
    marginTop: 20,
    padding: 15,
    backgroundColor: '#f8fafc',
    borderRadius: 4,
  },
  summaryTitle: {
    fontSize: 12,
    fontWeight: 'bold',
    marginBottom: 8,
    color: '#1e293b',
  },
  summaryRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: 4,
  },
  summaryLabel: {
    fontSize: 10,
    color: '#64748b',
  },
  summaryValue: {
    fontSize: 10,
    fontWeight: 'bold',
    color: '#1e293b',
  },
});

// Formatear fecha
const formatDate = (date: string | undefined): string => {
  if (!date) return '-';
  return new Date(date).toLocaleDateString('es-PE', {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
  });
};

// Formatear moneda
const formatCurrency = (value: number | undefined): string => {
  if (!value) return '-';
  return new Intl.NumberFormat('es-PE', {
    style: 'currency',
    currency: 'USD',
  }).format(value);
};

/**
 * Documento PDF para lista de proyectos
 */
interface ProjectsPDFProps {
  projects: Project[];
  title?: string;
}

function ProjectsPDF({ projects, title = 'Reporte de Proyectos' }: ProjectsPDFProps) {
  const totalBudget = projects.reduce((sum, p) => sum + (p.proBudget || 0), 0);
  const avgProgress = projects.length > 0
    ? Math.round(projects.reduce((sum, p) => sum + (p.proPro || 0), 0) / projects.length)
    : 0;

  return (
    <Document>
      <Page size="A4" style={styles.page}>
        <View style={styles.header}>
          <Text style={styles.title}>{title}</Text>
          <Text style={styles.subtitle}>ArchiStudio - Gestión de Proyectos</Text>
          <Text style={styles.date}>Generado: {new Date().toLocaleDateString('es-PE')}</Text>
        </View>

        <View style={styles.table}>
          <View style={styles.tableHeader}>
            <Text style={[styles.tableCellHeader, { flex: 2 }]}>Proyecto</Text>
            <Text style={[styles.tableCellHeader, { flex: 1.5 }]}>Cliente</Text>
            <Text style={styles.tableCellHeader}>Estado</Text>
            <Text style={styles.tableCellHeader}>Avance</Text>
            <Text style={styles.tableCellHeader}>Presupuesto</Text>
          </View>

          {projects.map((project, index) => (
            <View
              key={`${project.proYea}-${project.proCod}`}
              style={index % 2 === 0 ? styles.tableRow : styles.tableRowAlt}
            >
              <Text style={[styles.tableCell, { flex: 2 }]}>{project.proNam || '-'}</Text>
              <Text style={[styles.tableCell, { flex: 1.5 }]}>{project.cliNam || '-'}</Text>
              <Text style={styles.tableCell}>{project.proStaNam || '-'}</Text>
              <Text style={styles.tableCell}>{project.proPro || 0}%</Text>
              <Text style={styles.tableCell}>{formatCurrency(project.proBudget)}</Text>
            </View>
          ))}
        </View>

        <View style={styles.summary}>
          <Text style={styles.summaryTitle}>Resumen</Text>
          <View style={styles.summaryRow}>
            <Text style={styles.summaryLabel}>Total de proyectos:</Text>
            <Text style={styles.summaryValue}>{projects.length}</Text>
          </View>
          <View style={styles.summaryRow}>
            <Text style={styles.summaryLabel}>Presupuesto total:</Text>
            <Text style={styles.summaryValue}>{formatCurrency(totalBudget)}</Text>
          </View>
          <View style={styles.summaryRow}>
            <Text style={styles.summaryLabel}>Avance promedio:</Text>
            <Text style={styles.summaryValue}>{avgProgress}%</Text>
          </View>
        </View>

        <Text style={styles.footer}>
          ArchiStudio © {new Date().getFullYear()} - Documento generado automáticamente
        </Text>
      </Page>
    </Document>
  );
}

/**
 * Documento PDF para lista de presupuestos
 */
interface BudgetsPDFProps {
  budgets: Budget[];
  title?: string;
}

function BudgetsPDF({ budgets, title = 'Reporte de Presupuestos' }: BudgetsPDFProps) {
  const totalAmount = budgets.reduce((sum, b) => sum + (b.budTot || 0), 0);

  return (
    <Document>
      <Page size="A4" style={styles.page}>
        <View style={styles.header}>
          <Text style={styles.title}>{title}</Text>
          <Text style={styles.subtitle}>ArchiStudio - Gestión de Presupuestos</Text>
          <Text style={styles.date}>Generado: {new Date().toLocaleDateString('es-PE')}</Text>
        </View>

        <View style={styles.table}>
          <View style={styles.tableHeader}>
            <Text style={[styles.tableCellHeader, { flex: 2 }]}>Presupuesto</Text>
            <Text style={[styles.tableCellHeader, { flex: 1.5 }]}>Proyecto</Text>
            <Text style={styles.tableCellHeader}>Estado</Text>
            <Text style={styles.tableCellHeader}>Total</Text>
          </View>

          {budgets.map((budget, index) => (
            <View
              key={`${budget.budYea}-${budget.budCod}`}
              style={index % 2 === 0 ? styles.tableRow : styles.tableRowAlt}
            >
              <Text style={[styles.tableCell, { flex: 2 }]}>{budget.budNam || '-'}</Text>
              <Text style={[styles.tableCell, { flex: 1.5 }]}>{budget.proNam || '-'}</Text>
              <Text style={styles.tableCell}>{budget.budStaNam || '-'}</Text>
              <Text style={styles.tableCell}>{formatCurrency(budget.budTot)}</Text>
            </View>
          ))}
        </View>

        <View style={styles.summary}>
          <Text style={styles.summaryTitle}>Resumen</Text>
          <View style={styles.summaryRow}>
            <Text style={styles.summaryLabel}>Total de presupuestos:</Text>
            <Text style={styles.summaryValue}>{budgets.length}</Text>
          </View>
          <View style={styles.summaryRow}>
            <Text style={styles.summaryLabel}>Monto total:</Text>
            <Text style={styles.summaryValue}>{formatCurrency(totalAmount)}</Text>
          </View>
        </View>

        <Text style={styles.footer}>
          ArchiStudio © {new Date().getFullYear()} - Documento generado automáticamente
        </Text>
      </Page>
    </Document>
  );
}

/**
 * Exportar proyectos a PDF
 */
export async function exportProjectsToPDF(
  projects: Project[],
  filename = 'proyectos'
): Promise<void> {
  const blob = await pdf(<ProjectsPDF projects={projects} />).toBlob();
  saveAs(blob, `${filename}.pdf`);
}

/**
 * Exportar presupuestos a PDF
 */
export async function exportBudgetsToPDF(
  budgets: Budget[],
  filename = 'presupuestos'
): Promise<void> {
  const blob = await pdf(<BudgetsPDF budgets={budgets} />).toBlob();
  saveAs(blob, `${filename}.pdf`);
}

/**
 * Documento PDF para lista de clientes
 */
interface ClientsPDFProps {
  clients: Client[];
  title?: string;
}

function ClientsPDF({ clients, title = 'Reporte de Clientes' }: ClientsPDFProps) {
  const totalClients = clients.length;
  const personas = clients.filter(c => c.cliTyp === '01').length;
  const empresas = clients.filter(c => c.cliTyp === '02').length;

  return (
    <Document>
      <Page size="A4" style={styles.page}>
        <View style={styles.header}>
          <Text style={styles.title}>{title}</Text>
          <Text style={styles.subtitle}>ArchiStudio - Gestión de Clientes</Text>
          <Text style={styles.date}>Generado: {new Date().toLocaleDateString('es-PE')}</Text>
        </View>

        <View style={styles.table}>
          <View style={styles.tableHeader}>
            <Text style={[styles.tableCellHeader, { flex: 2 }]}>Nombre</Text>
            <Text style={styles.tableCellHeader}>Tipo</Text>
            <Text style={[styles.tableCellHeader, { flex: 1.5 }]}>Email</Text>
            <Text style={styles.tableCellHeader}>Teléfono</Text>
          </View>

          {clients.map((client, index) => (
            <View
              key={`${client.cliYea}-${client.cliCod}`}
              style={index % 2 === 0 ? styles.tableRow : styles.tableRowAlt}
            >
              <Text style={[styles.tableCell, { flex: 2 }]}>{client.cliNam || '-'}</Text>
              <Text style={styles.tableCell}>{client.cliTyp === '01' ? 'Persona' : 'Empresa'}</Text>
              <Text style={[styles.tableCell, { flex: 1.5 }]}>{client.cliEma || '-'}</Text>
              <Text style={styles.tableCell}>{client.cliPho || '-'}</Text>
            </View>
          ))}
        </View>

        <View style={styles.summary}>
          <Text style={styles.summaryTitle}>Resumen</Text>
          <View style={styles.summaryRow}>
            <Text style={styles.summaryLabel}>Total de clientes:</Text>
            <Text style={styles.summaryValue}>{totalClients}</Text>
          </View>
          <View style={styles.summaryRow}>
            <Text style={styles.summaryLabel}>Personas:</Text>
            <Text style={styles.summaryValue}>{personas}</Text>
          </View>
          <View style={styles.summaryRow}>
            <Text style={styles.summaryLabel}>Empresas:</Text>
            <Text style={styles.summaryValue}>{empresas}</Text>
          </View>
        </View>

        <Text style={styles.footer}>
          ArchiStudio © {new Date().getFullYear()} - Documento generado automáticamente
        </Text>
      </Page>
    </Document>
  );
}

/**
 * Exportar clientes a PDF
 */
export async function exportClientsToPDF(
  clients: Client[],
  filename = 'clientes'
): Promise<void> {
  const blob = await pdf(<ClientsPDF clients={clients} />).toBlob();
  saveAs(blob, `${filename}.pdf`);
}
