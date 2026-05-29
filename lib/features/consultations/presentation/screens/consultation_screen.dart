import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:typed_data';

import '../../../../core/utils/medsuite_toast.dart';
import '../../../../core/utils/platform_file_helper.dart';
import '../bloc/consultation_bloc.dart';
import '../../domain/entities/consultation_detail.dart';
import '../../domain/entities/consultation_catalog.dart';
import '../../../appointments/presentation/bloc/appointment_bloc.dart';

class ConsultationScreen extends StatefulWidget {
  final int citaId;
  final String? patientNameFallback;

  const ConsultationScreen({super.key, required this.citaId, this.patientNameFallback});

  @override
  State<ConsultationScreen> createState() => _ConsultationScreenState();
}

class _ConsultationScreenState extends State<ConsultationScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  ConsultationDetail? _currentDetail;
  ConsultationCatalog? _catalog;

  final List<String> _tabs = [
    'Enfermedad Actual',
    'Diagnóstico',
    'Signos Vitales',
    'Examen Físico',
    'Indicaciones',
    'Exámenes',
    'Receta',
    'Informe',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    context.read<ConsultationBloc>().add(FetchConsultationDetail(widget.citaId));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ConsultationBloc, ConsultationState>(
      listener: (context, state) {
        if (state is ConsultationError) {
          MedSuiteToast.show(context, message: state.message, type: ToastType.error);
        }
        if (state is ConsultationSaveSuccess) {
          MedSuiteToast.show(context, message: 'Guardado correctamente', type: ToastType.success);
          setState(() {
            _currentDetail = state.updatedDetail;
          });
          context.read<AppointmentBloc>().add(FetchDailyAppointments());
        }
        if (state is ConsultationLoaded) {
          setState(() {
            _currentDetail = state.detail;
            _catalog = state.catalog;
          });
        }
        if (state is ConsultationDownloadSuccess) {
          MedSuiteToast.show(context, message: "Abriendo documento...", type: ToastType.success);
          _saveAndOpenFile(state.bytes, state.fileName);
        }
      },
      builder: (context, state) {
        if (state is ConsultationLoading && _currentDetail == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: Color(0xFF1b448c))),
          );
        }

        return Stack(
          children: [
            Scaffold(
              backgroundColor: const Color(0xFFF8FAFC),
              body: (_currentDetail == null || _catalog == null)
                ? const Center(child: Text('Cargando datos...'))
                : _buildContent(_currentDetail!, _catalog!),
            ),
            if (state is ConsultationDownloading)
              Container(
                color: Colors.black26,
                child: const Center(
                  child: Card(
                    margin: EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: Color(0xFF1b448c)),
                        SizedBox(height: 16),
                        Text("Generando Documento...", style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildContent(ConsultationDetail detail, ConsultationCatalog catalog) {
    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(detail),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildPatientCard(detail),
          ),
        ),
        SliverPersistentHeader(
          pinned: true,
          delegate: _SliverAppBarDelegate(
            TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: const Color(0xFF1b448c),
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color(0xFF3BB5AB),
              indicatorWeight: 3,
              labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14),
              unselectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 14),
              tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
            ),
          ),
        ),
        SliverFillRemaining(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildEnfermedadActual(detail),
              _buildDiagnostico(detail),
              _buildSignosVitales(detail),
              _buildExamenFisico(detail, catalog),
              _buildIndicaciones(detail, catalog),
              _buildExamenes(detail, catalog),
              _buildReceta(detail),
              _buildInforme(detail),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSliverAppBar(ConsultationDetail detail) {
    return SliverAppBar(
      expandedHeight: 100.0,
      floating: false,
      pinned: true,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          "Seguimiento Médico",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xFF1b448c), Color(0xFF3BB5AB)],
            ),
          ),
        ),
      ),
      leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white), onPressed: () => Navigator.pop(context)),
      actions: [_buildStatusBadge(detail.estadoCita ?? "Pendiente"), const SizedBox(width: 8)],
    );
  }

  Widget _buildStatusBadge(String status) {
    final bool isAtendida = status.toLowerCase().contains("atendida");
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: isAtendida ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isAtendida ? Colors.green : Colors.orange),
        ),
        child: Text(
          status,
          style: GoogleFonts.inter(color: isAtendida ? Colors.green : Colors.orange, fontWeight: FontWeight.bold, fontSize: 11),
        ),
      ),
    );
  }

  Widget _buildPatientCard(ConsultationDetail detail) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFF1b448c).withOpacity(0.1),
                  child: Text(
                    (detail.pacienteNombre ?? "P").substring(0, 1).toUpperCase(),
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: const Color(0xFF1b448c)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(detail.pacienteNombre ?? "S/I", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: const Color(0xFF1b448c))),
                      Text("ID: ${detail.pacienteCedula ?? 'S/I'}", style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
                IconButton(icon: const Icon(Icons.edit_outlined, size: 20, color: Color(0xFF3BB5AB)), onPressed: () => _showEditPatientDialog(detail)),
              ],
            ),
            const Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildPatientInfoItem(Icons.person_outline, "Edad", "${detail.pacienteEdad ?? '?'} años"),
                _buildPatientInfoItem(Icons.wc, "Sexo", detail.pacienteSexo ?? "S/I"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientInfoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 12, color: Colors.grey),
        const SizedBox(width: 4),
        Text("$label: ", style: GoogleFonts.inter(fontSize: 11, color: Colors.grey)),
        Text(value, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 11, color: const Color(0xFF1e293b))),
      ],
    );
  }

  // --- Tabs Implementation ---

  Widget _buildEnfermedadActual(ConsultationDetail detail) {
    return _buildSectionBase(
      title: "Enfermedad Actual",
      hasData: detail.enfermedadActual.descripcion?.isNotEmpty ?? false,
      content: detail.enfermedadActual.descripcion ?? "",
      onAdd: () => _showEditClinicalSection("Enfermedad Actual", detail.enfermedadActual),
      extraActions: [
        TextButton.icon(onPressed: () => _showModoPrecargado(detail), icon: const Icon(Icons.auto_awesome, size: 16), label: const Text("Precargado", style: TextStyle(fontSize: 12)), style: TextButton.styleFrom(foregroundColor: const Color(0xFF3BB5AB))),
      ],
    );
  }

  Widget _buildDiagnostico(ConsultationDetail detail) {
    return _buildSectionBase(
      title: "Diagnóstico",
      hasData: detail.diagnostico.descripcion?.isNotEmpty ?? false,
      content: "${detail.diagnostico.codigoCIE10 ?? ''} - ${detail.diagnostico.descripcion ?? ''}",
      onAdd: () => _showEditClinicalSection("Diagnóstico", detail.diagnostico, showCIE10: true),
    );
  }

  Widget _buildSignosVitales(ConsultationDetail detail) {
    final sv = detail.signosVitales;
    final hasData = sv.tensionArterial != null || sv.temperatura != null;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Signos Vitales", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
              TextButton.icon(onPressed: () => _showEditSignosVitales(sv), icon: const Icon(Icons.edit, size: 18), label: const Text("Editar")),
            ],
          ),
          const SizedBox(height: 12),
          if (!hasData) _buildEmptyState("Sin signos registrados", () => _showEditSignosVitales(sv))
          else Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _buildVitalCard("T.A.", sv.tensionArterial ?? "N/A", Icons.favorite, Colors.red),
              _buildVitalCard("Temp", "${sv.temperatura ?? 'N/A'} °C", Icons.thermostat, Colors.orange),
              _buildVitalCard("F.C.", "${sv.frecuenciaCardiaca ?? 'N/A'} bpm", Icons.monitor_heart, Colors.blue),
              _buildVitalCard("F.R.", "${sv.frecuenciaRespiratoria ?? 'N/A'} rpm", Icons.air, Colors.teal),
              _buildVitalCard("SPO2", "${sv.saturacionOxigeno ?? 'N/A'} %", Icons.bloodtype, Colors.indigo),
              _buildVitalCard("Peso", "${sv.pesoKg ?? 'N/A'} kg", Icons.monitor_weight, Colors.brown),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVitalCard(String label, String value, IconData icon, Color color) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withOpacity(0.1))),
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildExamenFisico(ConsultationDetail detail, ConsultationCatalog catalog) {
    final ef = detail.examenFisico;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Examen Físico", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
              IconButton(icon: const Icon(Icons.add_box_outlined, color: Color(0xFF3BB5AB)), onPressed: () => _showConstructorHallazgos(catalog)),
            ],
          ),
          const SizedBox(height: 12),
          _buildPhysicalExamDisplay(ef),
        ],
      ),
    );
  }

  Widget _buildPhysicalExamDisplay(PhysicalExam ef) {
    final items = [
      if (ef.cabezaCuello?.isNotEmpty ?? false) _buildExamItem("Cabeza/Cuello", ef.cabezaCuello!),
      if (ef.torax?.isNotEmpty ?? false) _buildExamItem("Tórax", ef.torax!),
      if (ef.abdomen?.isNotEmpty ?? false) _buildExamItem("Abdomen", ef.abdomen!),
      if (ef.extremidades?.isNotEmpty ?? false) _buildExamItem("Extremidades", ef.extremidades!),
      if (ef.neurologico?.isNotEmpty ?? false) _buildExamItem("Neurológico", ef.neurologico!),
      if (ef.piel?.isNotEmpty ?? false) _buildExamItem("Piel", ef.piel!),
      if (ef.genitourinario?.isNotEmpty ?? false) _buildExamItem("Genitourinario", ef.genitourinario!),
      if (ef.observaciones?.isNotEmpty ?? false) _buildExamItem("Observaciones", ef.observaciones!),
    ];
    if (items.isEmpty) return _buildEmptyState("Sin hallazgos", () => _showConstructorHallazgos(_catalog!));
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade200)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: items),
    );
  }

  Widget _buildExamItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF1b448c))),
        Text(value, style: const TextStyle(fontSize: 13)),
      ]),
    );
  }

  Widget _buildIndicaciones(ConsultationDetail detail, ConsultationCatalog catalog) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Medicamentos", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
              IconButton(icon: const Icon(Icons.add_circle_outline, color: Color(0xFF3BB5AB)), onPressed: () => _showAddIndicationDialog(catalog)),
            ],
          ),
          const SizedBox(height: 12),
          if (detail.indicaciones.isEmpty) _buildEmptyState("Sin medicamentos", () => _showAddIndicationDialog(catalog))
          else ...detail.indicaciones.asMap().entries.map((e) => _buildIndicationCard(e.value, e.key)),
        ],
      ),
    );
  }

  Widget _buildIndicationCard(IndicationItem item, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(item.medicamento ?? "S/N", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1b448c)))),
              IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18), onPressed: () => _deleteIndication(index)),
            ],
          ),
          Text("${item.dosis ?? ''} - ${item.frecuencia ?? ''} (${item.viaAdministracion ?? ''})", style: const TextStyle(fontSize: 12)),
          if (item.indicaciones?.isNotEmpty ?? false) Text(item.indicaciones!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ]),
      ),
    );
  }

  Widget _buildExamenes(ConsultationDetail detail, ConsultationCatalog catalog) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Exámenes", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
              IconButton(icon: const Icon(Icons.add_circle_outline, color: Color(0xFF3BB5AB)), onPressed: () => _showAddExamDialog(catalog)),
            ],
          ),
          const SizedBox(height: 12),
          if (detail.examenesSolicitados.isEmpty) _buildEmptyState("Sin exámenes", () => _showAddExamDialog(catalog))
          else ...detail.examenesSolicitados.asMap().entries.map((e) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              dense: true,
              title: Text(e.value.nombreExamen ?? "S/N", style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("${e.value.tipoExamen ?? ''} - ${e.value.indicaciones ?? ''}"),
              trailing: IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18), onPressed: () => _deleteExam(e.key)),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildReceta(ConsultationDetail detail) {
    return _buildSectionBase(
      title: "Receta (Recipe)",
      hasData: detail.receta.descripcion?.isNotEmpty ?? false,
      content: "${detail.receta.descripcion ?? ''}\n\nIndicaciones: ${detail.receta.indicaciones ?? ''}",
      onAdd: () => _showEditPrescription(detail.receta),
      extraActions: [
        if (detail.receta.descripcion?.isNotEmpty ?? false)
          IconButton(
            icon: const Icon(Icons.print, color: Color(0xFF1b448c)),
            onPressed: () => context.read<ConsultationBloc>().add(DownloadPrescriptionRequested(detail.citaId)),
            tooltip: "Imprimir Receta",
          ),
      ],
    );
  }

  Widget _buildInforme(ConsultationDetail detail) {
    return _buildSectionBase(
      title: "Informe Médico",
      hasData: detail.informe.titulo?.isNotEmpty ?? false,
      content: "Título: ${detail.informe.titulo ?? ''}\nResumen: ${detail.informe.resumen ?? ''}\n\nConclusiones:\n${detail.informe.conclusiones ?? ''}\n\nRecomendaciones:\n${detail.informe.recomendaciones ?? ''}",
      onAdd: () => _showEditReport(detail.informe),
      extraActions: [
        if (detail.informe.titulo?.isNotEmpty ?? false)
          IconButton(
            icon: const Icon(Icons.print, color: Color(0xFF1b448c)),
            onPressed: () => _showPrintReportSelection(detail),
            tooltip: "Imprimir Informe",
          ),
      ],
    );
  }

  // --- Modals & Actions ---

  void _showConstructorHallazgos(ConsultationCatalog catalog) {
    CatalogItem? selectedExamen = catalog.physicalExam.examenes.isNotEmpty ? catalog.physicalExam.examenes.first : null;
    List<CatalogItem> filteredZonas = selectedExamen != null 
        ? catalog.physicalExam.zonas.where((z) => z.parentId == selectedExamen?.id).toList() 
        : [];
    CatalogItem? selectedZona = filteredZonas.isNotEmpty ? filteredZonas.first : null;
    final detController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Nuevo Hallazgo", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 20),
              DropdownButtonFormField<CatalogItem>(
                value: selectedExamen,
                decoration: const InputDecoration(labelText: "Examen", border: OutlineInputBorder()),
                items: catalog.physicalExam.examenes.map((e) => DropdownMenuItem(value: e, child: Text(e.nombre))).toList(),
                onChanged: (v) {
                  setModalState(() {
                    selectedExamen = v;
                    filteredZonas = catalog.physicalExam.zonas.where((z) => z.parentId == v?.id).toList();
                    selectedZona = filteredZonas.isNotEmpty ? filteredZonas.first : null;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<CatalogItem>(
                value: selectedZona,
                decoration: const InputDecoration(labelText: "Zona", border: OutlineInputBorder()),
                items: filteredZonas.map((e) => DropdownMenuItem(value: e, child: Text(e.nombre))).toList(),
                onChanged: (v) => setModalState(() => selectedZona = v),
              ),
              const SizedBox(height: 16),
              TextField(controller: detController, maxLines: 2, decoration: const InputDecoration(labelText: "Detalle", border: OutlineInputBorder())),
              const SizedBox(height: 24),
              SizedBox(width: double.infinity, height: 50, child: ElevatedButton(
                onPressed: () {
                  if (selectedExamen == null || selectedZona == null || detController.text.trim().isEmpty) {
                    MedSuiteToast.show(context, message: 'Complete todos los campos', type: ToastType.error);
                    return;
                  }
                  _addHallazgoToPhysicalExam(selectedZona!.nombre, "[${selectedExamen!.nombre} - ${selectedZona!.nombre}]: ${detController.text}");
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1b448c)),
                child: const Text("Añadir", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              )),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _addHallazgoToPhysicalExam(String zona, String text) {
    final ef = _currentDetail!.examenFisico;
    String z = zona.toLowerCase();
    
    String head = ef.cabezaCuello ?? "";
    String chest = ef.torax ?? "";
    String abd = ef.abdomen ?? "";
    String extr = ef.extremidades ?? "";
    String neuro = ef.neurologico ?? "";
    String skin = ef.piel ?? "";
    String gen = ef.genitourinario ?? "";
    String obs = ef.observaciones ?? "";

    if (z.contains("cabeza") || z.contains("cuello")) head += (head.isEmpty ? "" : "\n") + text;
    else if (z.contains("torax") || z.contains("tórax")) chest += (chest.isEmpty ? "" : "\n") + text;
    else if (z.contains("abdomen")) abd += (abd.isEmpty ? "" : "\n") + text;
    else if (z.contains("extremidad")) extr += (extr.isEmpty ? "" : "\n") + text;
    else if (z.contains("neuro")) neuro += (neuro.isEmpty ? "" : "\n") + text;
    else if (z.contains("piel")) skin += (skin.isEmpty ? "" : "\n") + text;
    else if (z.contains("genito")) gen += (gen.isEmpty ? "" : "\n") + text;
    else obs += (obs.isEmpty ? "" : "\n") + text;

    final newEF = PhysicalExam(cabezaCuello: head, torax: chest, abdomen: abd, extremidades: extr, neurologico: neuro, piel: skin, genitourinario: gen, observaciones: obs);
    context.read<ConsultationBloc>().add(SaveConsultationRequested(_copyWith(examenFisico: newEF)));
  }

  void _showAddIndicationDialog(ConsultationCatalog catalog) {
    final medController = TextEditingController();
    final doseController = TextEditingController();
    final freqController = TextEditingController();
    final daysController = TextEditingController();
    final instController = TextEditingController();
    CatalogItem? selectedVia = catalog.viasAdministracion.isNotEmpty ? catalog.viasAdministracion.first : null;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Medicamento", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
                TextField(controller: medController, decoration: const InputDecoration(labelText: "Fármaco *")),
                const SizedBox(height: 12),
                TextField(controller: doseController, decoration: const InputDecoration(labelText: "Dosis")),
                const SizedBox(height: 12),
                TextField(controller: freqController, decoration: const InputDecoration(labelText: "Frecuencia")),
                const SizedBox(height: 12),
                DropdownButtonFormField<CatalogItem>(
                  value: selectedVia,
                  decoration: const InputDecoration(labelText: "Vía"),
                  items: catalog.viasAdministracion.map((e) => DropdownMenuItem(value: e, child: Text(e.nombre))).toList(),
                  onChanged: (v) => setDialogState(() => selectedVia = v),
                ),
                const SizedBox(height: 12),
                TextField(controller: daysController, decoration: const InputDecoration(labelText: "Días"), keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                TextField(controller: instController, decoration: const InputDecoration(labelText: "Instrucciones")),
              ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
            ElevatedButton(
              onPressed: () {
                if (medController.text.isEmpty) {
                  MedSuiteToast.show(context, message: 'El nombre del fármaco es requerido', type: ToastType.error);
                  return;
                }
                final item = IndicationItem(medicamento: medController.text, dosis: doseController.text, frecuencia: freqController.text, viaAdministracion: selectedVia?.nombre, duracionDias: int.tryParse(daysController.text), indicaciones: instController.text, fechaInicio: DateTime.now().toString().split(' ')[0]);
                final newList = List<IndicationItem>.from(_currentDetail!.indicaciones)..add(item);
                context.read<ConsultationBloc>().add(SaveConsultationRequested(_copyWith(indicaciones: newList)));
                Navigator.pop(context);
              },
              child: const Text("Añadir", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddExamDialog(ConsultationCatalog catalog) {
    final nameController = TextEditingController();
    final instController = TextEditingController();
    CatalogItem? selectedType = catalog.tiposExamenSolicitado.isNotEmpty ? catalog.tiposExamenSolicitado.first : null;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Solicitud de Examen", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: "Nombre del Examen *")),
              const SizedBox(height: 16),
              DropdownButtonFormField<CatalogItem>(
                value: selectedType,
                decoration: const InputDecoration(labelText: "Tipo"),
                items: catalog.tiposExamenSolicitado.map((e) => DropdownMenuItem(value: e, child: Text(e.nombre))).toList(),
                onChanged: (v) => setDialogState(() => selectedType = v),
              ),
              const SizedBox(height: 16),
              TextField(controller: instController, decoration: const InputDecoration(labelText: "Instrucciones"), maxLines: 2),
            ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isEmpty) {
                  MedSuiteToast.show(context, message: 'El nombre del examen es requerido', type: ToastType.error);
                  return;
                }
                final item = ExamRequestItem(nombreExamen: nameController.text, tipoExamen: selectedType?.nombre, indicaciones: instController.text);
                final newList = List<ExamRequestItem>.from(_currentDetail!.examenesSolicitados)..add(item);
                context.read<ConsultationBloc>().add(SaveConsultationRequested(_copyWith(examenesSolicitados: newList)));
                Navigator.pop(context);
              },
              child: const Text("Añadir", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditPrescription(Prescription r) {
    final descController = TextEditingController(text: r.descripcion);
    final instController = TextEditingController(text: r.indicaciones);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text("Receta Médica", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 20),
            TextField(controller: descController, decoration: const InputDecoration(labelText: "Recipe (Medicamento y Presentación) *", border: OutlineInputBorder())),
            const SizedBox(height: 16),
            TextField(controller: instController, decoration: const InputDecoration(labelText: "Instrucciones de uso", border: OutlineInputBorder()), maxLines: 3),
            const SizedBox(height: 24),
            SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: () {
                  if (descController.text.isEmpty) {
                    MedSuiteToast.show(context, message: 'La descripción de la receta es requerida', type: ToastType.error);
                    return;
                  }
                  final now = DateTime.now();
                  final nextMonth = DateTime(now.year, now.month + 1, now.day);
                  final newR = Prescription(descripcion: descController.text, indicaciones: instController.text, fechaEmision: now.toString().split(' ')[0], fechaVencimiento: nextMonth.toString().split(' ')[0]);
                  context.read<ConsultationBloc>().add(SaveConsultationRequested(_copyWith(receta: newR)));
                  Navigator.pop(context);
                }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1b448c)), child: const Text("Guardar Receta", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
            const SizedBox(height: 20),
          ]),
      ),
    );
  }

  void _showEditReport(MedicalReport inf) {
    final titleController = TextEditingController(text: inf.titulo ?? "Informe Médico");
    final resController = TextEditingController(text: inf.resumen);
    final concController = TextEditingController(text: inf.conclusiones);
    final recController = TextEditingController(text: inf.recomendaciones);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text("Informe Médico", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 20),
              TextField(controller: titleController, decoration: const InputDecoration(labelText: "Título", border: OutlineInputBorder())),
              const SizedBox(height: 16),
              TextField(controller: resController, decoration: const InputDecoration(labelText: "Resumen", border: OutlineInputBorder())),
              const SizedBox(height: 16),
              TextField(controller: concController, decoration: const InputDecoration(labelText: "Conclusiones", border: OutlineInputBorder()), maxLines: 2),
              const SizedBox(height: 16),
              TextField(controller: recController, decoration: const InputDecoration(labelText: "Recomendaciones", border: OutlineInputBorder()), maxLines: 2),
              const SizedBox(height: 24),
              SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: () {
                    final newInf = MedicalReport(titulo: titleController.text, resumen: resController.text, conclusiones: concController.text, recomendaciones: recController.text, fechaInforme: DateTime.now().toString().split(' ')[0], adjuntoUrl: inf.adjuntoUrl);
                    context.read<ConsultationBloc>().add(SaveConsultationRequested(_copyWith(informe: newInf)));
                    Navigator.pop(context);
                  }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1b448c)), child: const Text("Guardar Informe", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
              const SizedBox(height: 20),
            ]),
        ),
      ),
    );
  }

  void _showPrintReportSelection(ConsultationDetail detail) {
    bool includeEnfermedad = true;
    bool includeDiagnostico = true;
    bool includeExamenFisico = true;
    bool includeSignosVitales = true;
    bool includeIndicaciones = true;
    bool includeInforme = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text("Seleccionar Secciones del Informe", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildCheckboxItem("Enfermedad Actual", includeEnfermedad, (v) => setDialogState(() => includeEnfermedad = v!)),
                _buildCheckboxItem("Diagnóstico", includeDiagnostico, (v) => setDialogState(() => includeDiagnostico = v!)),
                _buildCheckboxItem("Exámenes Físicos", includeExamenFisico, (v) => setDialogState(() => includeExamenFisico = v!)),
                _buildCheckboxItem("Signos Vitales", includeSignosVitales, (v) => setDialogState(() => includeSignosVitales = v!)),
                _buildCheckboxItem("Indicaciones Terapéuticas", includeIndicaciones, (v) => setDialogState(() => includeIndicaciones = v!)),
                _buildCheckboxItem("Informe Médico", includeInforme, (v) => setDialogState(() => includeInforme = v!)),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.read<ConsultationBloc>().add(DownloadReportRequested(
                  detail.citaId,
                  {
                    'enfermedadActual': includeEnfermedad,
                    'diagnostico': includeDiagnostico,
                    'examenesFisicos': includeExamenFisico,
                    'signosVitales': includeSignosVitales,
                    'indicaciones': includeIndicaciones,
                    'informeMedico': includeInforme,
                  },
                ));
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1b448c)),
              child: const Text("Imprimir", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckboxItem(String title, bool value, Function(bool?) onChanged) {
    return CheckboxListTile(
      title: Text(title, style: GoogleFonts.inter(fontSize: 14)),
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFF3BB5AB),
      dense: true,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  // --- Common Logic ---

  void _showEditClinicalSection(String title, ClinicalSection section, {bool showCIE10 = false}) {
    final controller = TextEditingController(text: section.descripcion);
    final cieController = TextEditingController(text: section.codigoCIE10);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 16),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text("Editar $title", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            if (showCIE10) ...[TextField(controller: cieController, decoration: const InputDecoration(labelText: "Código CIE-10", border: OutlineInputBorder())), const SizedBox(height: 12)],
            TextField(controller: controller, maxLines: 5, decoration: const InputDecoration(hintText: "Escriba aquí...", border: OutlineInputBorder())),
            const SizedBox(height: 24),
            SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: () { _savePartial(title, controller.text, cieController.text); Navigator.pop(context); }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1b448c)), child: const Text("Guardar", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
            const SizedBox(height: 20),
          ]),
      ),
    );
  }

  void _savePartial(String sectionTitle, String content, String cie10) {
    ConsultationDetail updated = _currentDetail!;
    if (sectionTitle == "Enfermedad Actual") updated = _copyWith(enfermedadActual: ClinicalSection(descripcion: content));
    else if (sectionTitle == "Diagnóstico") updated = _copyWith(diagnostico: ClinicalSection(descripcion: content, codigoCIE10: cie10));
    context.read<ConsultationBloc>().add(SaveConsultationRequested(updated));
  }

  void _deleteIndication(int index) {
    final newList = List<IndicationItem>.from(_currentDetail!.indicaciones)..removeAt(index);
    context.read<ConsultationBloc>().add(SaveConsultationRequested(_copyWith(indicaciones: newList)));
  }

  void _deleteExam(int index) {
    final newList = List<ExamRequestItem>.from(_currentDetail!.examenesSolicitados)..removeAt(index);
    context.read<ConsultationBloc>().add(SaveConsultationRequested(_copyWith(examenesSolicitados: newList)));
  }

  void _showEditSignosVitales(VitalSigns sv) {
    final tController = TextEditingController(text: sv.tensionArterial);
    final tempController = TextEditingController(text: sv.temperatura?.toString());
    final fcController = TextEditingController(text: sv.frecuenciaCardiaca?.toString());
    final frController = TextEditingController(text: sv.frecuenciaRespiratoria?.toString());
    final pesoController = TextEditingController(text: sv.pesoKg?.toString());
    final satController = TextEditingController(text: sv.saturacionOxigeno?.toString());
    final tallaController = TextEditingController(text: sv.estaturaCm?.toString());
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 16),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text("Signos Vitales", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 20),
            Row(children: [Expanded(child: _buildModalField(tController, "T.A.", "120/80")), const SizedBox(width: 12), Expanded(child: _buildModalField(tempController, "Temp", "37.0", isNumber: true))]),
            const SizedBox(height: 12),
            Row(children: [Expanded(child: _buildModalField(fcController, "F.C.", "80", isNumber: true)), const SizedBox(width: 12), Expanded(child: _buildModalField(frController, "F.R.", "20", isNumber: true))]),
            const SizedBox(height: 12),
            Row(children: [Expanded(child: _buildModalField(satController, "SPO2", "98", isNumber: true)), const SizedBox(width: 12), Expanded(child: _buildModalField(tallaController, "Talla", "170", isNumber: true))]),
            const SizedBox(height: 12),
            _buildModalField(pesoController, "Peso", "70.0", isNumber: true),
            const SizedBox(height: 24),
            SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: () {
                final newSV = VitalSigns(tensionArterial: tController.text, temperatura: double.tryParse(tempController.text), frecuenciaCardiaca: int.tryParse(fcController.text), frecuenciaRespiratoria: int.tryParse(frController.text), saturacionOxigeno: double.tryParse(satController.text), estaturaCm: double.tryParse(tallaController.text), pesoKg: double.tryParse(pesoController.text));
                context.read<ConsultationBloc>().add(SaveConsultationRequested(_copyWith(signosVitales: newSV)));
                Navigator.pop(context);
              }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1b448c)), child: const Text("Actualizar", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
            const SizedBox(height: 16),
          ]),
      ),
    );
  }

  void _showModoPrecargado(ConsultationDetail detail) {
    final sv = detail.signosVitales;
    String narrative = "Paciente ${detail.pacienteSexo == 'Femenino' ? 'femenino' : 'masculino'} de ${detail.pacienteEdad} años, quien acude por ${detail.motivoConsulta ?? 'consulta'}. ";
    if (sv.temperatura != null && sv.temperatura! > 37.5) narrative += "Presenta alza térmica de ${sv.temperatura}°C. ";
    narrative += "Refiere sintomatología de... ";
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Narrativa Médica", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Text(narrative),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cerrar")),
          ElevatedButton(onPressed: () { _savePartial("Enfermedad Actual", narrative, ""); Navigator.pop(context); }, child: const Text("Usar")),
        ],
      ),
    );
  }

  Widget _buildSectionBase({required String title, required bool hasData, required String content, required VoidCallback onAdd, List<Widget>? extraActions}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
              Row(children: [if (extraActions != null) ...extraActions, IconButton(icon: const Icon(Icons.edit_outlined, size: 20, color: Color(0xFF3BB5AB)), onPressed: onAdd)]),
            ],
          ),
          const SizedBox(height: 10),
          if (!hasData) _buildEmptyState("Sin información", onAdd)
          else Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade200)), child: Text(content, style: const TextStyle(fontSize: 13, height: 1.5))),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message, VoidCallback onAdd) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 20),
          Icon(Icons.note_add_outlined, size: 40, color: Colors.grey[300]),
          const SizedBox(height: 10),
          Text(message, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
          const SizedBox(height: 16),
          ElevatedButton.icon(onPressed: onAdd, icon: const Icon(Icons.add, size: 16), label: const Text("Agregar", style: TextStyle(fontSize: 12)), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1b448c), padding: const EdgeInsets.symmetric(horizontal: 16))),
        ],
      ),
    );
  }

  Widget _buildModalField(TextEditingController controller, String label, String hint, {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      decoration: InputDecoration(labelText: label, hintText: hint, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
    );
  }

  void _showEditPatientDialog(ConsultationDetail detail) {
    final ageController = TextEditingController(text: detail.pacienteEdad?.toString());
    String selectedSexo = detail.pacienteSexo ?? "Masculino";
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Paciente", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: ageController, decoration: const InputDecoration(labelText: "Edad"), keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: ["Masculino", "Femenino"].contains(selectedSexo) ? selectedSexo : "Masculino",
              decoration: const InputDecoration(labelText: "Sexo"),
              items: ["Masculino", "Femenino"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setDialogState(() => selectedSexo = v!),
            ),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
            ElevatedButton(onPressed: () { setState(() => _currentDetail = _copyWith(pacienteEdad: int.tryParse(ageController.text), pacienteSexo: selectedSexo)); Navigator.pop(context); }, child: const Text("Actualizar")),
          ],
        ),
      ),
    );
  }

  Future<void> _saveAndOpenFile(List<int> bytes, String fileName) async {
    try {
      await PlatformFileHelper.saveAndOpenFile(Uint8List.fromList(bytes), fileName);
    } catch (e) {
      MedSuiteToast.show(context, message: "Error al abrir el documento", type: ToastType.error);
    }
  }

  ConsultationDetail _copyWith({VitalSigns? signosVitales, ClinicalSection? enfermedadActual, PhysicalExam? examenFisico, ClinicalSection? diagnostico, List<IndicationItem>? indicaciones, List<ExamRequestItem>? examenesSolicitados, Prescription? receta, MedicalReport? informe, int? pacienteEdad, String? pacienteSexo}) {
    final d = _currentDetail!;
    return ConsultationDetail(citaId: d.citaId, fechaCita: d.fechaCita, motivoConsulta: d.motivoConsulta, estadoCita: d.estadoCita, pacienteNombre: d.pacienteNombre, pacienteCedula: d.pacienteCedula, pacienteEdad: pacienteEdad ?? d.pacienteEdad, pacienteSexo: pacienteSexo ?? d.pacienteSexo, signosVitales: signosVitales ?? d.signosVitales, enfermedadActual: enfermedadActual ?? d.enfermedadActual, examenFisico: examenFisico ?? d.examenFisico, diagnostico: diagnostico ?? d.diagnostico, indicaciones: indicaciones ?? d.indicaciones, examenesSolicitados: examenesSolicitados ?? d.examenesSolicitados, receta: receta ?? d.receta, informe: informe ?? d.informe);
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);
  final TabBar _tabBar;
  @override double get minExtent => _tabBar.preferredSize.height;
  @override double get maxExtent => _tabBar.preferredSize.height;
  @override Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => Container(color: Colors.white, child: _tabBar);
  @override bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}
