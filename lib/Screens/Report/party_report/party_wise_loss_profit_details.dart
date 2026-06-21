import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/currency.dart';
import 'package:mobile_pos/generated/l10n.dart' as l;
import '../../../GlobalComponents/glonal_popup.dart';
import '../../../constant.dart';
import '../../../service/check_user_role_permission_provider.dart';
import '../../../widgets/empty_widget/_empty_widget.dart';
import '../../Customers/Model/parties_model.dart';
import '../../Customers/Provider/customer_provider.dart';

class PartyWiseLossProfitDetails extends ConsumerStatefulWidget {
  final Party party;
  const PartyWiseLossProfitDetails({super.key, required this.party});

  @override
  ConsumerState<PartyWiseLossProfitDetails> createState() => _PartyWiseLossProfitDetailsState();
}

class _PartyWiseLossProfitDetailsState extends ConsumerState<PartyWiseLossProfitDetails> {
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

  @override
  Widget build(BuildContext context) {
    final permissionService = PermissionService(ref);
    final _theme = Theme.of(context);
    final _lang = l.S.of(context);

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
            _lang.details,
          ),
          bottom: PreferredSize(
            preferredSize: const Size(double.infinity, 70),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SizedBox(
                height: 45,
                child: TextFormField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchText = value;
                    });
                  },
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.zero,
                    visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
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
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
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
                          )
                        : null,
                    hintText: l.S.of(context).searchH,
                    hintStyle: _theme.textTheme.bodyMedium?.copyWith(color: kNeutralColor),
                  ),
                ),
              ),
            ),
          ),
        ),
        body: RefreshIndicator.adaptive(
          onRefresh: () => refreshData(ref),
          child: _buildTransactionList(context),
        ),
      ),
    );
  }

  Widget _buildTransactionList(BuildContext context) {
    final _theme = Theme.of(context);
    final _lang = l.S.of(context);
    final permissionService = PermissionService(ref);

    if (!permissionService.hasPermission(Permit.partiesRead.value)) {
      return const Center(child: PermitDenyWidget());
    }

    final transactions = widget.party.sales ?? [];

    final filteredTransactions = transactions
        .where((tx) => _searchText.isEmpty
            ? true
            : (tx.salesDetails ?? [])
                .any((d) => (d.product?.productName ?? '').toLowerCase().contains(_searchText.toLowerCase())))
        .toList();

    if (filteredTransactions.isEmpty) {
      return Center(child: EmptyWidget(message: TextSpan(text: l.S.of(context).noProductFound)));
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: filteredTransactions.length,
      itemBuilder: (_, index) {
        final tx = filteredTransactions[index];
        final details = tx.salesDetails ?? [];

        return Column(
          children: details
              .where((d) => _searchText.isEmpty
                  ? true
                  : (d.product?.productName ?? '').toLowerCase().contains(_searchText.toLowerCase()))
              .map(
            (d) {
              final profitLoss = d.lossProfit ?? 0;
              final profit = profitLoss > 0 ? profitLoss : 0;
              final loss = profitLoss < 0 ? profitLoss.abs() : 0;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          d.product?.productName ?? '',
                          style: _theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w500),
                        ),
                        Text(
                          '${l.S.of(context).qty}: ${d.quantities ?? 0}',
                          style: _theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_lang.purchasePrice}: $currency${formatPointNumber(d.productPurchasePrice ?? 0, addComma: true)}',
                          style: _theme.textTheme.bodyMedium,
                        ),
                        Text(
                          '${_lang.salePrice}: $currency${formatPointNumber(d.price ?? 0, addComma: true)}',
                          style: _theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_lang.loss}: $currency${formatPointNumber(loss, addComma: true)}',
                          style: _theme.textTheme.bodyMedium?.copyWith(color: Colors.red),
                        ),
                        Text(
                          '${_lang.profit}: $currency${formatPointNumber(profit, addComma: true)}',
                          style: _theme.textTheme.bodyMedium?.copyWith(color: Colors.green),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ).toList(),
        );
      },
      separatorBuilder: (_, __) => const Divider(thickness: 1, height: 1, color: kLineColor),
    );
  }
}
