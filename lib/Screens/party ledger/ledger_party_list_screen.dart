import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobile_pos/Screens/Customers/Provider/customer_provider.dart';
import 'single_party_ledger_screen.dart';
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:mobile_pos/widgets/empty_widget/_empty_widget.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../GlobalComponents/glonal_popup.dart';
import '../../Provider/profile_provider.dart';
import '../../currency.dart';
import '../../pdf_report/ledger_report_pdf/customer_ledger_report_pdf.dart';
import '../../pdf_report/ledger_report_pdf/supplier_ledger_report_pdf.dart';
import '../../service/check_user_role_permission_provider.dart';
import '../Customers/Model/parties_model.dart';

class LedgerPartyListScreen extends StatefulWidget {
  const LedgerPartyListScreen({
    super.key,
    this.isReport = false,
    this.type,
  });
  final bool isReport;
  final String? type;

  @override
  State<LedgerPartyListScreen> createState() => _LedgerPartyListScreenState();
}

class _LedgerPartyListScreenState extends State<LedgerPartyListScreen> {
  bool _isRefreshing = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  Future<void> refreshData(WidgetRef ref) async {
    if (_isRefreshing) return;
    _isRefreshing = true;
    ref.refresh(partiesProvider);
    await Future.delayed(const Duration(seconds: 1));
    _isRefreshing = false;
  }

  List<String> get availablePartyTypes {
    if (widget.isReport) {
      // Report mode
      if (widget.type == 'supplier') {
        return ['Supplier'];
      }
      return ['All Party', 'Customer', 'Dealer', 'Wholesaler'];
    }
    return ['All', 'Customer', 'Supplier', 'Dealer', 'Wholesaler'];
  }

  String getPartyLegerTypeLabel(String value) {
    switch (value) {
      case 'All':
        return lang.S.current.all;
      case 'All Party':
        return lang.S.current.allParty;
      case 'Customer':
        return lang.S.current.customer;
      case 'Supplier':
        return lang.S.current.supplier;
      case 'Dealer':
        return lang.S.current.dealer;
      case 'Wholesaler':
        return lang.S.current.wholesaler;
      default:
        return value; // fallback
    }
  }

  String? selectedPartyType;

  @override
  void initState() {
    super.initState();

    if (widget.isReport) {
      selectedPartyType = widget.type == 'supplier' ? 'Supplier' : 'All Party';
    } else {
      selectedPartyType = 'All';
    }
  }

  List<Party> getFilteredParties(List<Party> partyList) {
    return partyList.where((c) {
      final normalizedType = (c.type ?? '').toLowerCase();
      final effectiveType = normalizedType == 'retailer' ? 'customer' : normalizedType;

      final nameMatches = _searchText.isEmpty ||
          (c.name ?? '').toLowerCase().contains(_searchText.toLowerCase()) ||
          (c.phone ?? '').contains(_searchText);

      // -------- REPORT MODE --------
      if (widget.isReport) {
        if (widget.type == 'supplier') {
          return effectiveType == 'supplier' && nameMatches;
        }

        if (selectedPartyType == 'All Party') {
          return (effectiveType == 'customer' || effectiveType == 'dealer' || effectiveType == 'wholesaler') &&
              nameMatches;
        }

        return effectiveType == selectedPartyType!.toLowerCase() && nameMatches;
      }

      if (selectedPartyType == 'All') {
        return nameMatches;
      }

      return effectiveType == selectedPartyType!.toLowerCase() && nameMatches;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, __) {
        final providerData = ref.watch(partiesProvider);
        final businessInfo = ref.watch(businessInfoProvider);
        final permissionService = PermissionService(ref);
        final _theme = Theme.of(context);
        final _lang = lang.S.of(context);

        return businessInfo.when(
            data: (details) {
              return GlobalPopup(
                child: Scaffold(
                  backgroundColor: kWhite,
                  appBar: AppBar(
                    backgroundColor: kWhite,
                    surfaceTintColor: kWhite,
                    elevation: 0,
                    centerTitle: true,
                    iconTheme: const IconThemeData(color: Colors.black),
                    title: Text(
                      _lang.ledger,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    actions: [
                      if (widget.isReport)
                        businessInfo.when(
                          data: (business) {
                            return providerData.when(
                              data: (partyList) {
                                final permissionService = PermissionService(ref);

                                /// 🔹 IMPORTANT: use filtered list
                                final filteredParties = getFilteredParties(partyList);

                                return Row(
                                  children: [
                                    /// ================= PDF =================
                                    IconButton(
                                      icon: HugeIcon(
                                        icon: HugeIcons.strokeRoundedPdf02,
                                        color: kSecondayColor,
                                      ),
                                      onPressed: () {
                                        // ---------- PERMISSION ----------
                                        final hasPermission = widget.type == 'supplier'
                                            ? permissionService.hasPermission(Permit.saleReportsRead.value)
                                            : permissionService.hasPermission(Permit.saleReportsRead.value);

                                        if (!hasPermission) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              backgroundColor: Colors.red,
                                              content: Text(_lang.youDoNotHavePermissionToGenerateReport),
                                            ),
                                          );
                                          return;
                                        }

                                        // ---------- EMPTY CHECK ----------
                                        if (filteredParties.isEmpty) {
                                          EasyLoading.showError(_lang.noDataAvailabe);
                                          return;
                                        }

                                        // ---------- GENERATE PDF ----------
                                        if (widget.isReport && widget.type == 'customer') {
                                          generateCustomerLedgerReportPdf(
                                            context,
                                            filteredParties,
                                            business,
                                          );
                                        } else {
                                          generateSupplierLedgerReportPdf(
                                            context,
                                            filteredParties,
                                            business,
                                          );
                                        }
                                      },
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                );
                              },
                              loading: () => const SizedBox.shrink(),
                              error: (_, __) => const SizedBox.shrink(),
                            );
                          },
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) => const SizedBox.shrink(),
                        ),
                    ],
                  ),
                  body: RefreshIndicator.adaptive(
                    onRefresh: () => refreshData(ref),
                    child: providerData.when(
                        data: (partyList) {
                          if (!permissionService.hasPermission(Permit.partiesRead.value)) {
                            return const Center(child: PermitDenyWidget());
                          }
                          // --- 1. Calculate All Summary in ONE Loop ---
                          double totalCustomerDue = 0;
                          double totalSupplierDue = 0;
                          double summaryDue = 0;

                          for (var party in partyList) {
                            final normalizedType = (party.type ?? '').toLowerCase();
                            final effectiveType = normalizedType == 'retailer' ? 'customer' : normalizedType;

                            final due = party.due ?? 0;
                            if (due <= 0) continue;

                            // --- TOTALS ---
                            if (effectiveType == 'customer') {
                              totalCustomerDue += due;
                            }

                            if (effectiveType == 'supplier') {
                              totalSupplierDue += due;
                            }

                            // --- SUMMARY BASED ON FILTER ---
                            if (widget.isReport) {
                              if (selectedPartyType == 'All Party') {
                                if (effectiveType == 'customer' ||
                                    effectiveType == 'dealer' ||
                                    effectiveType == 'wholesaler') {
                                  summaryDue += due;
                                }
                              } else {
                                if (effectiveType == selectedPartyType!.toLowerCase()) {
                                  summaryDue += due;
                                }
                              }
                            } else {
                              if (selectedPartyType == 'All') {
                                summaryDue += due;
                              } else if (effectiveType == selectedPartyType!.toLowerCase()) {
                                summaryDue += due;
                              }
                            }
                          }
                          final filteredParties = getFilteredParties(partyList);

                          return Column(
                            children: [
                              // --- SUMMARY DISPLAY ---
                              if (selectedPartyType != 'All')
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                                  child: Container(
                                    height: 90,
                                    width: double.infinity,
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: const Color(0xffFFE5F9),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        // 🔹 Updated with myFormatNumber 🔹
                                        Text("$currency${myFormatNumber(summaryDue)}",
                                            style: _theme.textTheme.titleLarge?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            )),
                                        const SizedBox(height: 4),
                                        Text(
                                          "${getPartyLegerTypeLabel(selectedPartyType ?? 'All')} ${_lang.due}",
                                          style: _theme.textTheme.titleSmall?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: kPeraColor,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              // --- Summary Cards ---
                              if (selectedPartyType == 'All')
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                                  child: Row(
                                    children: [
                                      // Customer Due Card
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: const Color(0xffFFE5F9),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Column(
                                            children: [
                                              // 🔹 Updated with myFormatNumber 🔹
                                              Text('$currency${myFormatNumber(totalCustomerDue)}',
                                                  style: _theme.textTheme.titleLarge?.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 18,
                                                  )),
                                              const SizedBox(height: 4),
                                              Text(
                                                _lang.customerDue,
                                                textAlign: TextAlign.center,
                                                style: _theme.textTheme.titleSmall?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  color: kPeraColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      // Supplier Due Card
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF5F001A).withValues(alpha: 0.1), // Beige Light
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Column(
                                            children: [
                                              // 🔹 Updated with myFormatNumber 🔹
                                              Text(
                                                '$currency${myFormatNumber(totalSupplierDue)}',
                                                style: _theme.textTheme.titleLarge?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 18,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                _lang.supplierDue,
                                                textAlign: TextAlign.center,
                                                style: _theme.textTheme.titleSmall?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  color: kPeraColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              Row(
                                children: [
                                  Flexible(
                                    flex: 5,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: TextFormField(
                                        controller: _searchController,
                                        onChanged: (value) {
                                          setState(() {
                                            _searchText = value;
                                          });
                                        },
                                        decoration: InputDecoration(
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8),
                                              borderSide: const BorderSide(color: updateBorderColor, width: 1),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8),
                                              borderSide: const BorderSide(color: Colors.red, width: 1),
                                            ),
                                            prefixIcon: const Padding(
                                              padding: EdgeInsets.only(left: 10),
                                              child: Icon(
                                                FeatherIcons.search,
                                                color: kNeutralColor,
                                              ),
                                            ),
                                            suffixIcon: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                if (_searchController.text.isNotEmpty)
                                                  IconButton(
                                                    visualDensity: const VisualDensity(horizontal: -4),
                                                    tooltip: _lang.clear,
                                                    onPressed: () {
                                                      _searchController.clear();
                                                      setState(() {
                                                        _searchText = '';
                                                      });
                                                    },
                                                    icon: Icon(
                                                      Icons.close,
                                                      size: 20,
                                                      color: kSubPeraColor,
                                                    ),
                                                  ),
                                                if (!(widget.isReport && widget.type == 'supplier'))
                                                  GestureDetector(
                                                    onTap: () {
                                                      _showFilterBottomSheet(context);
                                                    },
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(1.0),
                                                      child: Container(
                                                        width: 50,
                                                        height: 45,
                                                        padding: const EdgeInsets.all(8),
                                                        decoration: BoxDecoration(
                                                          color: kMainColor50,
                                                          borderRadius: const BorderRadius.only(
                                                            topRight: Radius.circular(5),
                                                            bottomRight: Radius.circular(5),
                                                          ),
                                                        ),
                                                        child: SvgPicture.asset('assets/filter.svg'),
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            hintText: lang.S.of(context).searchH,
                                            hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                  color: kNeutralColor,
                                                )),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              // --- List View ---
                              Expanded(
                                child: filteredParties.isEmpty
                                    ? Center(child: EmptyWidget(message: TextSpan(text: lang.S.of(context).noParty)))
                                    : ListView.builder(
                                        itemCount: filteredParties.length,
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        itemBuilder: (_, index) {
                                          final party = filteredParties[index];
                                          return _buildPartyTile(party, context, ref);
                                        },
                                      ),
                              ),
                            ],
                          );
                        },
                        error: (e, stack) => Text(e.toString()),
                        loading: () => const Center(child: CircularProgressIndicator())),
                  ),
                ),
              );
            },
            error: (e, stack) => Text(e.toString()),
            loading: () => const Center(child: CircularProgressIndicator()));
      },
    );
  }

  // --- Helper Widgets & Methods ---

  Widget _buildPartyTile(Party party, BuildContext context, WidgetRef ref) {
    final normalizedType = (party.type ?? '').toLowerCase();
    String effectiveDisplayType;

    if (normalizedType == 'retailer') {
      effectiveDisplayType = lang.S.of(context).customer;
    } else if (normalizedType == 'wholesaler') {
      effectiveDisplayType = lang.S.of(context).wholesaler;
    } else if (normalizedType == 'dealer') {
      effectiveDisplayType = lang.S.of(context).dealer;
    } else if (normalizedType == 'supplier') {
      effectiveDisplayType = lang.S.of(context).supplier;
    } else {
      effectiveDisplayType = normalizedType ?? '';
    }

    // Status & Color Logic
    String statusText;
    Color statusColor;
    num? statusAmount;

    if (party.due != null && party.due! > 0) {
      statusText = 'Due';
      statusColor = kDueColor; // Red
      statusAmount = party.due;
    } else if (party.openingBalanceType?.toLowerCase() == 'advance' && party.wallet != null && party.wallet! > 0) {
      statusText = 'Advance';
      statusColor = kAdvanceColor; // Green
      statusAmount = party.wallet;
    } else {
      statusText = lang.S.of(context).noDue;
      statusColor = kPeraColor;
      statusAmount = null;
    }

    final _theme = Theme.of(context);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      visualDensity: VisualDensity(horizontal: -3, vertical: -2),
      onTap: () {
        PartyLedgerScreen(
          partyId: party.id.toString(),
          partyName: party.name.toString(),
        ).launch(context);
      },
      // Avatar
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: kMainColor50,
        backgroundImage: (party.image != null && party.image!.isNotEmpty) ? NetworkImage('${party.image}') : null,
        child: (party.image == null || party.image!.isEmpty)
            ? Text(
                (party.name != null && party.name!.length >= 2)
                    ? party.name!.substring(0, 2)
                    : (party.name != null ? party.name! : ''),
                style: _theme.textTheme.titleMedium?.copyWith(
                  color: kMainColor,
                  fontWeight: FontWeight.w500,
                ),
              )
            : null,
      ),
      // Name and Type
      title: Text(
        party.name ?? '',
        style: _theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        effectiveDisplayType,
        style: _theme.textTheme.bodySmall?.copyWith(
          color: kPeraColor,
        ),
      ),
      // Amount and Status
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (statusAmount != null)
                // 🔹 Updated with myFormatNumber 🔹
                Text(
                  '$currency${myFormatNumber(statusAmount)}',
                  style: _theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              Text(
                statusText,
                style: _theme.textTheme.bodySmall?.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: kPeraColor,
          ),
        ],
      ),
    );
  }

  // --- Bottom Sheet Filter ---
  void _showFilterBottomSheet(BuildContext context) {
    String? tempSelectedType = selectedPartyType;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsetsGeometry.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        lang.S.of(context).filter,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                        style: IconButton.styleFrom(
                          padding: EdgeInsets.zero,
                        ),
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                const Divider(
                  color: kLineColor,
                  height: 1,
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: '${lang.S.of(context).partyType}*',
                        ),
                        hint: Text(lang.S.of(context).selectOne),
                        initialValue: tempSelectedType,
                        items: availablePartyTypes.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(
                              getPartyLegerTypeLabel(type),
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: kTitleColor),
                            ),
                          );
                        }).toList(),
                        onChanged: (widget.isReport && widget.type == 'supplier')
                            ? null
                            : (val) {
                                setModalState(() {
                                  tempSelectedType = val;
                                });
                              },
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setModalState(() {
                                  tempSelectedType = 'All';
                                });
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.red),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                lang.S.of(context).clear,
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  selectedPartyType = tempSelectedType;
                                });
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFB71C1C), // Deep Red
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                lang.S.of(context).apply,
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
