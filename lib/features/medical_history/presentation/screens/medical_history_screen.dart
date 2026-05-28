import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/medsuite_toast.dart';
import '../bloc/medical_history_bloc.dart';
import '../../domain/entities/medical_history.dart';

class MedicalHistoryScreen extends StatefulWidget {
  final int patientId;
  final String patientName;

  const MedicalHistoryScreen({super.key, required this.patientId, required this.patientName});

  @override
  State<MedicalHistoryScreen> createState() => _MedicalHistoryScreenState();
}

class _MedicalHistoryScreenState extends State<MedicalHistoryScreen> {
  @override
  void initState() {
    super.initState();
    context.read<MedicalHistoryBloc>().add(FetchMedicalHistory(widget.patientId));
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF2563EB);
    const textDark = Color(0xFF1E293B);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: Text('Historia Médica', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: textDark,
        elevation: 0,
      ),
      body: BlocConsumer<MedicalHistoryBloc, MedicalHistoryState>(
        listener: (context, state) {
          if (state is MedicalHistoryError) {
            MedSuiteToast.show(context, message: state.message, type: ToastType.error);
          }
          if (state is MedicalHistoryUpdateSuccess || state is MedicalHistoryAddSuccess) {
            MedSuiteToast.show(context, message: 'Registro actualizado correctamente', type: ToastType.success);
            context.read<MedicalHistoryBloc>().add(FetchMedicalHistory(widget.patientId));
          }
        },
        builder: (context, state) {
          if (state is MedicalHistoryLoading) {
            return const Center(child: CircularProgressIndicator(color: primaryBlue));
          }

          if (state is MedicalHistoryLoaded) {
            final history = state.history;
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPatientBanner(history),
                  const SizedBox(height: 24),
                  _buildBasicDataSection(history),
                  const SizedBox(height: 24),
                  _buildDetailsSection(history),
                ],
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildPatientBanner(FullMedicalHistory history) {
    final name = history.patientName ?? widget.patientName;
    final idCard = history.patientIdCard ?? 'Sin identificación';
    final initials = name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2563EB),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            child: Text(
              initials,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Cédula: $idCard',
                  style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicDataSection(FullMedicalHistory history) {
    final data = history.datosBasicos;
    final bool isNew = history.historiaMedicaId == 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('DATOS ANTROPOMÉTRICOS', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade500, letterSpacing: 1.2)),
              IconButton(
                onPressed: () => _showEditBasicDataDialog(history),
                icon: Icon(isNew ? Icons.add_circle_outline : Icons.edit_outlined, size: 20, color: const Color(0xFF2563EB)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetricItem('Peso', data.pesoGeneralKg ?? "No reg.", Icons.monitor_weight_outlined),
              _buildMetricItem('Talla', data.estaturaGeneral ?? "No reg.", Icons.height_outlined),
              _buildMetricItem('Sangre', data.tipoSangreNombre ?? 'No reg.', Icons.bloodtype_outlined),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, IconData icon) {
    final bool isNotRegistered = value == "No reg." || value == "No registrado";
    return Column(
      children: [
        Icon(icon, color: isNotRegistered ? Colors.grey.shade300 : const Color(0xFF64748B), size: 24),
        const SizedBox(height: 8),
        Text(
          value, 
          style: GoogleFonts.poppins(
            fontSize: 15, 
            fontWeight: FontWeight.bold, 
            color: isNotRegistered ? Colors.grey.shade400 : const Color(0xFF1E293B)
          )
        ),
        Text(label, style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF64748B))),
      ],
    );
  }

  Widget _buildDetailsSection(FullMedicalHistory history) {
    final detalles = history.detalles;
    
    // Lista de categorías clínicas requeridas
    final List<String> mandatoryCategories = [
      'antecedentesAlergicos',
      'antecedentesFamiliares',
      'antecedentesPersonales',
      'antecedentesQuirurgicos',
      'habitosPsicobiologicos',
      'antecedentesOdontologicos',
    ];

    final technicalKeys = {
      'success', 'message', 'error', 'errors', 'count', 'data', 'status',
      'historiaMedicaId', 'datosBasicos', 'detalles', 'paciente'
    };

    // Combinamos las obligatorias con las que traiga el API (filtrando metadatos)
    final Set<String> allVisibleKeys = {
      ...mandatoryCategories,
      ...detalles.keys.where((key) => !technicalKeys.contains(key.toLowerCase()))
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('ANTECEDENTES Y DETALLES', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade500, letterSpacing: 1.2)),
        const SizedBox(height: 16),
        ...allVisibleKeys.map((key) => _buildDetailCard(
          history.historiaMedicaId, 
          key, 
          detalles[key] ?? []
        )),
      ],
    );
  }

  Widget _buildDetailCard(int historiaId, String categoryKey, List<dynamic> items) {
    String displayTitle = categoryKey.replaceAll(RegExp(r'(?=[A-Z])'), ' ').toUpperCase().trim();
    if (categoryKey.toLowerCase().contains('alergicos')) displayTitle = 'ALERGIAS';
    if (categoryKey.toLowerCase().contains('familiares')) displayTitle = 'ANTECEDENTES FAMILIARES';
    if (categoryKey.toLowerCase().contains('personales')) displayTitle = 'ANTECEDENTES PERSONALES';
    if (categoryKey.toLowerCase().contains('quirurgicos')) displayTitle = 'ANTECEDENTES QUIRÚRGICOS';
    if (categoryKey.toLowerCase().contains('habitos')) displayTitle = 'HÁBITOS PSICOBIOLÓGICOS';
    if (categoryKey.toLowerCase().contains('odontologicos')) displayTitle = 'ODONTOGRAMA / DENTAL';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
      child: ExpansionTile(
        title: Text(displayTitle, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
        leading: Icon(
          categoryKey.toLowerCase().contains('odontologicos') ? Icons.medical_information_outlined : Icons.folder_shared_outlined, 
          color: const Color(0xFF2563EB)
        ),
        children: [
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20), 
              child: Text('Sin registros actuales', style: GoogleFonts.inter(color: Colors.grey.shade400, fontSize: 13))
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade100),
              itemBuilder: (context, index) {
                final item = items[index];
                return ListTile(
                  title: Text(
                    item['descripcion'] ?? item['Nombre'] ?? item['alergia'] ?? item['enfermedad'] ?? 'Registro ${index + 1}', 
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)
                  ),
                  subtitle: _buildItemSubtitle(item),
                  trailing: const Icon(Icons.info_outline, size: 18, color: Color(0xFF94A3B8)),
                );
              },
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                TextButton.icon(
                  onPressed: () => _showAddAntecedentDialog(historiaId, categoryKey),
                  icon: const Icon(Icons.add_circle_outline, size: 18),
                  label: const Text('Registrar Nuevo'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget? _buildItemSubtitle(dynamic item) {
    List<String> details = [];
    if (item['reaccion'] != null) details.add('Reacción: ${item['reaccion']}');
    if (item['parentesco'] != null) details.add('Parentesco: ${item['parentesco']}');
    if (item['tratamiento'] != null) details.add('Tratamiento: ${item['tratamiento']}');
    
    if (details.isEmpty) return null;
    return Text(details.join(' • '), style: GoogleFonts.inter(fontSize: 12));
  }

  void _showEditBasicDataDialog(FullMedicalHistory history) {
    final pesoController = TextEditingController(text: history.datosBasicos.pesoGeneralKg);
    final tallaController = TextEditingController(text: history.datosBasicos.estaturaGeneral);
    int selectedSangre = history.datosBasicos.tipoSangreId ?? 1;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Datos Antropométricos', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: pesoController, 
              decoration: const InputDecoration(labelText: 'Peso (kg)', hintText: 'Ej: 70', prefixIcon: Icon(Icons.monitor_weight_outlined)), 
              keyboardType: TextInputType.number
            ),
            const SizedBox(height: 24),
            TextField(
              controller: tallaController, 
              decoration: const InputDecoration(labelText: 'Talla (cm)', hintText: 'Ej: 175', prefixIcon: Icon(Icons.height_outlined)), 
              keyboardType: TextInputType.number
            ),
            const SizedBox(height: 24),
            DropdownButtonFormField<int>(
              value: selectedSangre,
              decoration: const InputDecoration(labelText: 'Tipo de Sangre', filled: true, fillColor: Color(0xFFF1F5F9), border: OutlineInputBorder(borderSide: BorderSide.none), prefixIcon: Icon(Icons.bloodtype_outlined)),
              items: const [
                DropdownMenuItem(value: 1, child: Text('O+')),
                DropdownMenuItem(value: 2, child: Text('O-')),
                DropdownMenuItem(value: 3, child: Text('A+')),
                DropdownMenuItem(value: 4, child: Text('A-')),
              ],
              onChanged: (v) => selectedSangre = v!,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              if (history.historiaMedicaId == 0) {
                 MedSuiteToast.show(context, message: "Error: El paciente no tiene un expediente creado.", type: ToastType.error);
                 Navigator.pop(context);
                 return;
              }
              context.read<MedicalHistoryBloc>().add(UpdateBasicDataRequested(
                historyId: history.historiaMedicaId,
                data: {
                  'tipoSangreId': selectedSangre,
                  'pesoGeneralKg': pesoController.text,
                  'estaturaGeneral': tallaController.text,
                },
              ));
              Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showAddAntecedentDialog(int historiaId, String categoryKey) {
    final titleController = TextEditingController();
    final detailController = TextEditingController();
    
    String titleLabel = 'Descripción';
    String detailLabel = 'Observaciones / Reacción';
    
    if (categoryKey.toLowerCase().contains('alergicos')) {
      titleLabel = 'Alergia';
      detailLabel = 'Reacción';
    } else if (categoryKey.toLowerCase().contains('familiares')) {
      titleLabel = 'Enfermedad';
      detailLabel = 'Parentesco';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Nuevo Registro', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController, 
              decoration: InputDecoration(labelText: titleLabel, prefixIcon: const Icon(Icons.edit_note_outlined))
            ),
            const SizedBox(height: 24),
            TextField(
              controller: detailController, 
              decoration: InputDecoration(labelText: detailLabel, prefixIcon: const Icon(Icons.info_outline)), 
              maxLines: 2
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              if (historiaId == 0) {
                 MedSuiteToast.show(context, message: "Error: El paciente no tiene un ID de historia asignado.", type: ToastType.error);
                 Navigator.pop(context);
                 return;
              }
              Map<String, dynamic> data = {};
              final lowKey = categoryKey.toLowerCase();
              
              if (lowKey.contains('alergicos')) {
                data = {'alergia': titleController.text, 'reaccion': detailController.text, 'medicamento': 'Ninguno', 'complicacion': false};
              } else if (lowKey.contains('familiares')) {
                data = {'enfermedad': titleController.text, 'parentesco': detailController.text, 'vive': true};
              } else {
                data = {'tipo': titleController.text, 'observaciones': detailController.text};
              }

              context.read<MedicalHistoryBloc>().add(AddAntecedentRequested(
                historyId: historiaId,
                category: categoryKey.replaceAll('antecedentes', '').toLowerCase(),
                data: data,
              ));
              Navigator.pop(context);
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }
}
