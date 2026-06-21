// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false) ? locale.languageCode : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Select State`
  String get selectState {
    return Intl.message(
      'Select State',
      name: 'selectState',
      desc: '',
      args: [],
    );
  }

  /// `Select Country`
  String get selectCountry {
    return Intl.message(
      'Select Country',
      name: 'selectCountry',
      desc: '',
      args: [],
    );
  }

  /// `Select Country First`
  String get selectCountyFirst {
    return Intl.message(
      'Select Country First',
      name: 'selectCountyFirst',
      desc: '',
      args: [],
    );
  }

  /// `No Internet Connection`
  String get noInternetConnection {
    return Intl.message(
      'No Internet Connection',
      name: 'noInternetConnection',
      desc: '',
      args: [],
    );
  }

  /// `Total Qty`
  String get totalQty {
    return Intl.message('Total Qty', name: 'totalQty', desc: '', args: []);
  }

  /// `No Tax Found`
  String get noTaxFound {
    return Intl.message('No Tax Found', name: 'noTaxFound', desc: '', args: []);
  }

  /// `Tax name is required`
  String get taxNameIsRequired {
    return Intl.message(
      'Tax name is required',
      name: 'taxNameIsRequired',
      desc: '',
      args: [],
    );
  }

  /// `Tax required is required`
  String get taxRateIsRequired {
    return Intl.message(
      'Tax required is required',
      name: 'taxRateIsRequired',
      desc: '',
      args: [],
    );
  }

  /// `Enter a valid number`
  String get enterAValidNumber {
    return Intl.message(
      'Enter a valid number',
      name: 'enterAValidNumber',
      desc: '',
      args: [],
    );
  }

  /// `You do not have permission to create tax.`
  String get youDoNotHavePermissionToCreateTax {
    return Intl.message(
      'You do not have permission to create tax.',
      name: 'youDoNotHavePermissionToCreateTax',
      desc: '',
      args: [],
    );
  }

  /// `You do not have permission to update tax.`
  String get youDoNotHavePermissionToUpdateTax {
    return Intl.message(
      'You do not have permission to update tax.',
      name: 'youDoNotHavePermissionToUpdateTax',
      desc: '',
      args: [],
    );
  }

  /// `Manage State`
  String get manageState {
    return Intl.message(
      'Manage State',
      name: 'manageState',
      desc: '',
      args: [],
    );
  }

  /// `Select Inner Vats`
  String get selectInnerVats {
    return Intl.message(
      'Select Inner Vats',
      name: 'selectInnerVats',
      desc: '',
      args: [],
    );
  }

  /// `Select Outer Vats`
  String get selectOuterVats {
    return Intl.message(
      'Select Outer Vats',
      name: 'selectOuterVats',
      desc: '',
      args: [],
    );
  }

  /// `Please select Inner or Outer taxes`
  String get pleaseSelectInnerOrOtherTax {
    return Intl.message(
      'Please select Inner or Outer taxes',
      name: 'pleaseSelectInnerOrOtherTax',
      desc: '',
      args: [],
    );
  }

  /// `Please select taxes`
  String get pleaseSelectTaxes {
    return Intl.message(
      'Please select taxes',
      name: 'pleaseSelectTaxes',
      desc: '',
      args: [],
    );
  }

  /// `You do not have permission to delete tax`
  String get youDoNotHavePermissionToDeleteTax {
    return Intl.message(
      'You do not have permission to delete tax',
      name: 'youDoNotHavePermissionToDeleteTax',
      desc: '',
      args: [],
    );
  }

  /// `Tax No`
  String get taxNo {
    return Intl.message('Tax No', name: 'taxNo', desc: '', args: []);
  }

  /// `Enter Tax Number`
  String get enterTaxNumber {
    return Intl.message(
      'Enter Tax Number',
      name: 'enterTaxNumber',
      desc: '',
      args: [],
    );
  }

  /// `Rates`
  String get rates {
    return Intl.message('Rates', name: 'rates', desc: '', args: []);
  }

  /// `Branch Transfer`
  String get branchTransfer {
    return Intl.message(
      'Branch Transfer',
      name: 'branchTransfer',
      desc: '',
      args: [],
    );
  }

  /// `Tax Invoice`
  String get taxInvoice {
    return Intl.message('Tax Invoice', name: 'taxInvoice', desc: '', args: []);
  }

  /// `Invoice No.`
  String get invoiceNo {
    return Intl.message('Invoice No.', name: 'invoiceNo', desc: '', args: []);
  }

  /// `Invoice Date`
  String get invoiceDate {
    return Intl.message(
      'Invoice Date',
      name: 'invoiceDate',
      desc: '',
      args: [],
    );
  }

  /// `Order Reference`
  String get orderReference {
    return Intl.message(
      'Order Reference',
      name: 'orderReference',
      desc: '',
      args: [],
    );
  }

  /// `Payment Reference`
  String get paymentReference {
    return Intl.message(
      'Payment Reference',
      name: 'paymentReference',
      desc: '',
      args: [],
    );
  }

  /// `Bill To`
  String get billTo {
    return Intl.message('Bill To', name: 'billTo', desc: '', args: []);
  }

  /// `Item Description`
  String get itemDescription {
    return Intl.message(
      'Item Description',
      name: 'itemDescription',
      desc: '',
      args: [],
    );
  }

  /// `Taxable Value`
  String get taxableValue {
    return Intl.message(
      'Taxable Value',
      name: 'taxableValue',
      desc: '',
      args: [],
    );
  }

  /// `Total Price Include Tax`
  String get totalPriceIncludeTax {
    return Intl.message(
      'Total Price Include Tax',
      name: 'totalPriceIncludeTax',
      desc: '',
      args: [],
    );
  }

  /// `Include Tax Price`
  String get includeTaxPrice {
    return Intl.message(
      'Include Tax Price',
      name: 'includeTaxPrice',
      desc: '',
      args: [],
    );
  }

  /// `Party Ledger`
  String get partyLedger {
    return Intl.message(
      'Party Ledger',
      name: 'partyLedger',
      desc: '',
      args: [],
    );
  }

  /// `Powered By {url}`
  String poweredByUrl(Object url) {
    return Intl.message(
      'Powered By $url',
      name: 'poweredByUrl',
      desc: '',
      args: [url],
    );
  }

  /// `TRANSFER INVOICE`
  String get transferInvoice {
    return Intl.message(
      'TRANSFER INVOICE',
      name: 'transferInvoice',
      desc: '',
      args: [],
    );
  }

  /// `Serial`
  String get serial {
    return Intl.message('Serial', name: 'serial', desc: '', args: []);
  }

  /// `Page`
  String get page {
    return Intl.message('Page', name: 'page', desc: '', args: []);
  }

  /// `Credit`
  String get credit {
    return Intl.message('Credit', name: 'credit', desc: '', args: []);
  }

  /// `Debit`
  String get debit {
    return Intl.message('Debit', name: 'debit', desc: '', args: []);
  }

  /// `Day Book Report`
  String get dayBookReport {
    return Intl.message(
      'Day Book Report',
      name: 'dayBookReport',
      desc: '',
      args: [],
    );
  }

  /// `All Transaction Report`
  String get allTransactionReport {
    return Intl.message(
      'All Transaction Report',
      name: 'allTransactionReport',
      desc: '',
      args: [],
    );
  }

  /// `Bill Wise Profit Report`
  String get billWiseProfitReport {
    return Intl.message(
      'Bill Wise Profit Report',
      name: 'billWiseProfitReport',
      desc: '',
      args: [],
    );
  }

  /// `Cash Flow Report`
  String get cashFlowReport {
    return Intl.message(
      'Cash Flow Report',
      name: 'cashFlowReport',
      desc: '',
      args: [],
    );
  }

  /// `Balance Sheet Report`
  String get balanceSheetReport {
    return Intl.message(
      'Balance Sheet Report',
      name: 'balanceSheetReport',
      desc: '',
      args: [],
    );
  }

  /// `Profit & Loss Report`
  String get profitAndLossReport {
    return Intl.message(
      'Profit & Loss Report',
      name: 'profitAndLossReport',
      desc: '',
      args: [],
    );
  }

  /// `Expense Type`
  String get expenseType {
    return Intl.message(
      'Expense Type',
      name: 'expenseType',
      desc: '',
      args: [],
    );
  }

  /// `Vat Value`
  String get vatValue {
    return Intl.message('Vat Value', name: 'vatValue', desc: '', args: []);
  }

  /// `Category Description`
  String get categoryDescription {
    return Intl.message(
      'Category Description',
      name: 'categoryDescription',
      desc: '',
      args: [],
    );
  }

  /// `Sale Price`
  String get salesPrice {
    return Intl.message('Sale Price', name: 'salesPrice', desc: '', args: []);
  }

  /// `Sold Qty`
  String get soldQty {
    return Intl.message('Sold Qty', name: 'soldQty', desc: '', args: []);
  }

  /// `Remaining Qty`
  String get remainingQty {
    return Intl.message(
      'Remaining Qty',
      name: 'remainingQty',
      desc: '',
      args: [],
    );
  }

  /// `Cost Price`
  String get costPrice {
    return Intl.message('Cost Price', name: 'costPrice', desc: '', args: []);
  }

  /// `Payment By`
  String get paymentBy {
    return Intl.message('Payment By', name: 'paymentBy', desc: '', args: []);
  }

  /// `Customer Ledger Report`
  String get customerLedgerReport {
    return Intl.message(
      'Customer Ledger Report',
      name: 'customerLedgerReport',
      desc: '',
      args: [],
    );
  }

  /// `Supplier Ledger Report`
  String get supplierLedgerReport {
    return Intl.message(
      'Supplier Ledger Report',
      name: 'supplierLedgerReport',
      desc: '',
      args: [],
    );
  }

  /// `Party Name`
  String get partyName {
    return Intl.message('Party Name', name: 'partyName', desc: '', args: []);
  }

  /// `Sale Amount`
  String get saleAmount {
    return Intl.message('Sale Amount', name: 'saleAmount', desc: '', args: []);
  }

  /// `Party Wise Loss & Profit Report`
  String get partyWiseLossProfitReport {
    return Intl.message(
      'Party Wise Loss & Profit Report',
      name: 'partyWiseLossProfitReport',
      desc: '',
      args: [],
    );
  }

  /// `Top 5 Customer`
  String get topFiveCustomer {
    return Intl.message(
      'Top 5 Customer',
      name: 'topFiveCustomer',
      desc: '',
      args: [],
    );
  }

  /// `Expire In`
  String get expiredIn {
    return Intl.message('Expire In', name: 'expiredIn', desc: '', args: []);
  }

  /// `Generate Complete`
  String get generateComplete {
    return Intl.message(
      'Generate Complete',
      name: 'generateComplete',
      desc: '',
      args: [],
    );
  }

  /// `Error`
  String get error {
    return Intl.message('Error', name: 'error', desc: '', args: []);
  }

  /// `Product Wise Sale`
  String get productWiseSale {
    return Intl.message(
      'Product Wise Sale',
      name: 'productWiseSale',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete your account? This action will permanently erase all your data.`
  String get deleteDialogDetails {
    return Intl.message(
      'Are you sure you want to delete your account? This action will permanently erase all your data.',
      name: 'deleteDialogDetails',
      desc: '',
      args: [],
    );
  }

  /// `Password must be at least 6 characters`
  String get passwordMust6Character {
    return Intl.message(
      'Password must be at least 6 characters',
      name: 'passwordMust6Character',
      desc: '',
      args: [],
    );
  }

  /// `Password must be at least 6 characters`
  String get passwordIsRequired {
    return Intl.message(
      'Password must be at least 6 characters',
      name: 'passwordIsRequired',
      desc: '',
      args: [],
    );
  }

  /// `I agree to delete my account permanently.`
  String get iAgreeDeleteMyAccountPermanent {
    return Intl.message(
      'I agree to delete my account permanently.',
      name: 'iAgreeDeleteMyAccountPermanent',
      desc: '',
      args: [],
    );
  }

  /// `Flat`
  String get flat {
    return Intl.message('Flat', name: 'flat', desc: '', args: []);
  }

  /// `Percent`
  String get percent {
    return Intl.message('Percent', name: 'percent', desc: '', args: []);
  }

  /// `Partial Paid`
  String get partialPaid {
    return Intl.message(
      'Partial Paid',
      name: 'partialPaid',
      desc: '',
      args: [],
    );
  }

  /// `Select Stock`
  String get selectStock {
    return Intl.message(
      'Select Stock',
      name: 'selectStock',
      desc: '',
      args: [],
    );
  }

  /// `Stock / Variant`
  String get stockOrVariant {
    return Intl.message(
      'Stock / Variant',
      name: 'stockOrVariant',
      desc: '',
      args: [],
    );
  }

  /// `No Batch`
  String get noBatch {
    return Intl.message('No Batch', name: 'noBatch', desc: '', args: []);
  }

  /// `Purchase quantity required`
  String get purchaseQuantityRequired {
    return Intl.message(
      'Purchase quantity required',
      name: 'purchaseQuantityRequired',
      desc: '',
      args: [],
    );
  }

  /// `Excel Uploader`
  String get excelUploader {
    return Intl.message(
      'Excel Uploader',
      name: 'excelUploader',
      desc: '',
      args: [],
    );
  }

  /// `Remove`
  String get remove {
    return Intl.message('Remove', name: 'remove', desc: '', args: []);
  }

  /// `Uploading...`
  String get uploading {
    return Intl.message('Uploading...', name: 'uploading', desc: '', args: []);
  }

  /// `Pick and Upload File`
  String get pickAndUploadFile {
    return Intl.message(
      'Pick and Upload File',
      name: 'pickAndUploadFile',
      desc: '',
      args: [],
    );
  }

  /// `Download Excel Format`
  String get downloadExcelFormat {
    return Intl.message(
      'Download Excel Format',
      name: 'downloadExcelFormat',
      desc: '',
      args: [],
    );
  }

  /// `Excel Files`
  String get excelFiles {
    return Intl.message('Excel Files', name: 'excelFiles', desc: '', args: []);
  }

  /// `No file selected`
  String get noFileSelected {
    return Intl.message(
      'No file selected',
      name: 'noFileSelected',
      desc: '',
      args: [],
    );
  }

  /// `WH`
  String get WH {
    return Intl.message('WH', name: 'WH', desc: '', args: []);
  }

  /// `Product & Pricing`
  String get productAndPricing {
    return Intl.message(
      'Product & Pricing',
      name: 'productAndPricing',
      desc: '',
      args: [],
    );
  }

  /// `IMEI/Serial`
  String get imeiAndSerial {
    return Intl.message(
      'IMEI/Serial',
      name: 'imeiAndSerial',
      desc: '',
      args: [],
    );
  }

  /// `Please generate variations`
  String get pleaseGenerateVariations {
    return Intl.message(
      'Please generate variations',
      name: 'pleaseGenerateVariations',
      desc: '',
      args: [],
    );
  }

  /// `Please add products to combo`
  String get pleaseAddProductCombo {
    return Intl.message(
      'Please add products to combo',
      name: 'pleaseAddProductCombo',
      desc: '',
      args: [],
    );
  }

  /// `Enable Serial Addon to modify stock for serial items`
  String get enableSerialAddonToModifyStockForSerialNumbers {
    return Intl.message(
      'Enable Serial Addon to modify stock for serial items',
      name: 'enableSerialAddonToModifyStockForSerialNumbers',
      desc: '',
      args: [],
    );
  }

  /// `Serial Number`
  String get serialNumber {
    return Intl.message(
      'Serial Number',
      name: 'serialNumber',
      desc: '',
      args: [],
    );
  }

  /// `Update Successfully`
  String get updateSuccessfully {
    return Intl.message(
      'Update Successfully',
      name: 'updateSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Please Try Again!`
  String get pleaseTryAgain {
    return Intl.message(
      'Please Try Again!',
      name: 'pleaseTryAgain',
      desc: '',
      args: [],
    );
  }

  /// `Add IMEI/Serial`
  String get addImeiOrSerial {
    return Intl.message(
      'Add IMEI/Serial',
      name: 'addImeiOrSerial',
      desc: '',
      args: [],
    );
  }

  /// `Entered`
  String get entered {
    return Intl.message('Entered', name: 'entered', desc: '', args: []);
  }

  /// `Search/Type serial number`
  String get searchOrTypeSerialNumber {
    return Intl.message(
      'Search/Type serial number',
      name: 'searchOrTypeSerialNumber',
      desc: '',
      args: [],
    );
  }

  /// `No serials added yet`
  String get noSerialAddedYet {
    return Intl.message(
      'No serials added yet',
      name: 'noSerialAddedYet',
      desc: '',
      args: [],
    );
  }

  /// `Warehouse List`
  String get warehouseList {
    return Intl.message(
      'Warehouse List',
      name: 'warehouseList',
      desc: '',
      args: [],
    );
  }

  /// `Transfer List`
  String get transferList {
    return Intl.message(
      'Transfer List',
      name: 'transferList',
      desc: '',
      args: [],
    );
  }

  /// `Stock Qty`
  String get stockQty {
    return Intl.message('Stock Qty', name: 'stockQty', desc: '', args: []);
  }

  /// `Add Warehouse`
  String get addWarehouse {
    return Intl.message(
      'Add Warehouse',
      name: 'addWarehouse',
      desc: '',
      args: [],
    );
  }

  /// `Add Transfer`
  String get addTransfer {
    return Intl.message(
      'Add Transfer',
      name: 'addTransfer',
      desc: '',
      args: [],
    );
  }

  /// `Ooph... it's empty in here`
  String get oophItsEmptyInHere {
    return Intl.message(
      'Ooph... it\'s empty in here',
      name: 'oophItsEmptyInHere',
      desc: '',
      args: [],
    );
  }

  /// `Add some items first`
  String get addSomeItemsFirst {
    return Intl.message(
      'Add some items first',
      name: 'addSomeItemsFirst',
      desc: '',
      args: [],
    );
  }

  /// `Enter warehouse name`
  String get pleaseEnterWarehouseName {
    return Intl.message(
      'Enter warehouse name',
      name: 'pleaseEnterWarehouseName',
      desc: '',
      args: [],
    );
  }

  /// `Enter phone number`
  String get enterPhoneNumber {
    return Intl.message(
      'Enter phone number',
      name: 'enterPhoneNumber',
      desc: '',
      args: [],
    );
  }

  /// `Enter your email address (optional)`
  String get enterYourEmailAddressOptional {
    return Intl.message(
      'Enter your email address (optional)',
      name: 'enterYourEmailAddressOptional',
      desc: '',
      args: [],
    );
  }

  /// `Enter a valid email address`
  String get enterAValidEmailAddress {
    return Intl.message(
      'Enter a valid email address',
      name: 'enterAValidEmailAddress',
      desc: '',
      args: [],
    );
  }

  /// `Enter a valid email address`
  String get enterYourAddress {
    return Intl.message(
      'Enter a valid email address',
      name: 'enterYourAddress',
      desc: '',
      args: [],
    );
  }

  /// `Edit Department`
  String get editDepartment {
    return Intl.message(
      'Edit Department',
      name: 'editDepartment',
      desc: '',
      args: [],
    );
  }

  /// `Department Name`
  String get departmentName {
    return Intl.message(
      'Department Name',
      name: 'departmentName',
      desc: '',
      args: [],
    );
  }

  /// `Enter Department Name`
  String get enterDepartmentName {
    return Intl.message(
      'Enter Department Name',
      name: 'enterDepartmentName',
      desc: '',
      args: [],
    );
  }

  /// `Please Enter Department Name`
  String get pleaseEnterDepartmentName {
    return Intl.message(
      'Please Enter Department Name',
      name: 'pleaseEnterDepartmentName',
      desc: '',
      args: [],
    );
  }

  /// `Add Transfer Items`
  String get addTransferItem {
    return Intl.message(
      'Add Transfer Items',
      name: 'addTransferItem',
      desc: '',
      args: [],
    );
  }

  /// `Select Batch`
  String get selectBranch {
    return Intl.message(
      'Select Batch',
      name: 'selectBranch',
      desc: '',
      args: [],
    );
  }

  /// `Edit Transfer`
  String get editTransfer {
    return Intl.message(
      'Edit Transfer',
      name: 'editTransfer',
      desc: '',
      args: [],
    );
  }

  /// `Add New Transfer`
  String get addNewTransfer {
    return Intl.message(
      'Add New Transfer',
      name: 'addNewTransfer',
      desc: '',
      args: [],
    );
  }

  /// `From Branch`
  String get fromBranch {
    return Intl.message('From Branch', name: 'fromBranch', desc: '', args: []);
  }

  /// `To Branch`
  String get toBranch {
    return Intl.message('To Branch', name: 'toBranch', desc: '', args: []);
  }

  /// `From Warehouse (Optional)`
  String get fromWarehouseOptional {
    return Intl.message(
      'From Warehouse (Optional)',
      name: 'fromWarehouseOptional',
      desc: '',
      args: [],
    );
  }

  /// `From Warehouse`
  String get fromWarehouse {
    return Intl.message(
      'From Warehouse',
      name: 'fromWarehouse',
      desc: '',
      args: [],
    );
  }

  /// `To Warehouse (Optional)`
  String get toWarehouseOptional {
    return Intl.message(
      'To Warehouse (Optional)',
      name: 'toWarehouseOptional',
      desc: '',
      args: [],
    );
  }

  /// `To Warehouse`
  String get toWarehouse {
    return Intl.message(
      'To Warehouse',
      name: 'toWarehouse',
      desc: '',
      args: [],
    );
  }

  /// `No items added`
  String get noItemAdded {
    return Intl.message(
      'No items added',
      name: 'noItemAdded',
      desc: '',
      args: [],
    );
  }

  /// `Transfer Note`
  String get transferNote {
    return Intl.message(
      'Transfer Note',
      name: 'transferNote',
      desc: '',
      args: [],
    );
  }

  /// `Type note...`
  String get typeNote {
    return Intl.message('Type note...', name: 'typeNote', desc: '', args: []);
  }

  /// `Update Transfer`
  String get updateTransfer {
    return Intl.message(
      'Update Transfer',
      name: 'updateTransfer',
      desc: '',
      args: [],
    );
  }

  /// `Pending`
  String get pending {
    return Intl.message('Pending', name: 'pending', desc: '', args: []);
  }

  /// `Cancelled`
  String get cancelled {
    return Intl.message('Cancelled', name: 'cancelled', desc: '', args: []);
  }

  /// `Completed`
  String get completed {
    return Intl.message('Completed', name: 'completed', desc: '', args: []);
  }

  /// `No employees found.`
  String get noEmployeeFound {
    return Intl.message(
      'No employees found.',
      name: 'noEmployeeFound',
      desc: '',
      args: [],
    );
  }

  /// `No results found for`
  String get noResultFoundFor {
    return Intl.message(
      'No results found for',
      name: 'noResultFoundFor',
      desc: '',
      args: [],
    );
  }

  /// `You do not have permission to update Employee.`
  String get youDoNotHavePermissionToUpdateEmployee {
    return Intl.message(
      'You do not have permission to update Employee.',
      name: 'youDoNotHavePermissionToUpdateEmployee',
      desc: '',
      args: [],
    );
  }

  /// `Add Employee`
  String get addEmployee {
    return Intl.message(
      'Add Employee',
      name: 'addEmployee',
      desc: '',
      args: [],
    );
  }

  /// `Terminated`
  String get terminated {
    return Intl.message('Terminated', name: 'terminated', desc: '', args: []);
  }

  /// `Suspended`
  String get suspended {
    return Intl.message('Suspended', name: 'suspended', desc: '', args: []);
  }

  /// `Male`
  String get male {
    return Intl.message('Male', name: 'male', desc: '', args: []);
  }

  /// `Female`
  String get female {
    return Intl.message('Female', name: 'female', desc: '', args: []);
  }

  /// `Others`
  String get others {
    return Intl.message('Others', name: 'others', desc: '', args: []);
  }

  /// `No leave types found.`
  String get noLeaveTypeFound {
    return Intl.message(
      'No leave types found.',
      name: 'noLeaveTypeFound',
      desc: '',
      args: [],
    );
  }

  /// `No results found for`
  String get noRequestFoundFor {
    return Intl.message(
      'No results found for',
      name: 'noRequestFoundFor',
      desc: '',
      args: [],
    );
  }

  /// `No description`
  String get noDescription {
    return Intl.message(
      'No description',
      name: 'noDescription',
      desc: '',
      args: [],
    );
  }

  /// `Add Leave Type`
  String get addLeaveType {
    return Intl.message(
      'Add Leave Type',
      name: 'addLeaveType',
      desc: '',
      args: [],
    );
  }

  /// `You do not have permission to update Leave Type.`
  String get youDoNotHavePermissionUpdateTheLeaveType {
    return Intl.message(
      'You do not have permission to update Leave Type.',
      name: 'youDoNotHavePermissionUpdateTheLeaveType',
      desc: '',
      args: [],
    );
  }

  /// `You do not have permission to delete Leave Type.`
  String get youDoNotHavePermissionDeleteTheLeaveType {
    return Intl.message(
      'You do not have permission to delete Leave Type.',
      name: 'youDoNotHavePermissionDeleteTheLeaveType',
      desc: '',
      args: [],
    );
  }

  /// `Edit Leave Type`
  String get editLeaveType {
    return Intl.message(
      'Edit Leave Type',
      name: 'editLeaveType',
      desc: '',
      args: [],
    );
  }

  /// `Add New Leave Type`
  String get addNewLeaveType {
    return Intl.message(
      'Add New Leave Type',
      name: 'addNewLeaveType',
      desc: '',
      args: [],
    );
  }

  /// `Enter leave type name`
  String get enterLeaveTypeName {
    return Intl.message(
      'Enter leave type name',
      name: 'enterLeaveTypeName',
      desc: '',
      args: [],
    );
  }

  /// `Please Enter leave type name`
  String get pleaseEnterLeaveTypeName {
    return Intl.message(
      'Please Enter leave type name',
      name: 'pleaseEnterLeaveTypeName',
      desc: '',
      args: [],
    );
  }

  /// `Select a status`
  String get selectAStatus {
    return Intl.message(
      'Select a status',
      name: 'selectAStatus',
      desc: '',
      args: [],
    );
  }

  /// `All Employee`
  String get allEmployees {
    return Intl.message(
      'All Employee',
      name: 'allEmployees',
      desc: '',
      args: [],
    );
  }

  /// `Morning`
  String get morning {
    return Intl.message('Morning', name: 'morning', desc: '', args: []);
  }

  /// `Day`
  String get day {
    return Intl.message('Day', name: 'day', desc: '', args: []);
  }

  /// `Night`
  String get night {
    return Intl.message('Night', name: 'night', desc: '', args: []);
  }

  /// `Evening`
  String get evening {
    return Intl.message('Evening', name: 'evening', desc: '', args: []);
  }

  /// `January`
  String get january {
    return Intl.message('January', name: 'january', desc: '', args: []);
  }

  /// `February`
  String get february {
    return Intl.message('February', name: 'february', desc: '', args: []);
  }

  /// `March`
  String get march {
    return Intl.message('March', name: 'march', desc: '', args: []);
  }

  /// `April`
  String get april {
    return Intl.message('April', name: 'april', desc: '', args: []);
  }

  /// `May`
  String get may {
    return Intl.message('May', name: 'may', desc: '', args: []);
  }

  /// `June`
  String get june {
    return Intl.message('June', name: 'june', desc: '', args: []);
  }

  /// `July`
  String get july {
    return Intl.message('July', name: 'july', desc: '', args: []);
  }

  /// `August`
  String get august {
    return Intl.message('August', name: 'august', desc: '', args: []);
  }

  /// `September`
  String get september {
    return Intl.message('September', name: 'september', desc: '', args: []);
  }

  /// `October`
  String get october {
    return Intl.message('October', name: 'october', desc: '', args: []);
  }

  /// `November`
  String get november {
    return Intl.message('November', name: 'november', desc: '', args: []);
  }

  /// `December`
  String get december {
    return Intl.message('December', name: 'december', desc: '', args: []);
  }

  /// `All Month`
  String get allMonth {
    return Intl.message('All Month', name: 'allMonth', desc: '', args: []);
  }

  /// `HRM`
  String get hrms {
    return Intl.message('HRM', name: 'hrms', desc: '', args: []);
  }

  /// `Approved`
  String get approved {
    return Intl.message('Approved', name: 'approved', desc: '', args: []);
  }

  /// `Rejected`
  String get rejected {
    return Intl.message('Rejected', name: 'rejected', desc: '', args: []);
  }

  /// `Or Continue with`
  String get orContinueWith {
    return Intl.message(
      'Or Continue with',
      name: 'orContinueWith',
      desc: '',
      args: [],
    );
  }

  /// `Login X`
  String get loginX {
    return Intl.message('Login X', name: 'loginX', desc: '', args: []);
  }

  /// `Login Google`
  String get loginGoogle {
    return Intl.message(
      'Login Google',
      name: 'loginGoogle',
      desc: '',
      args: [],
    );
  }

  /// `Login failed. Please try again.`
  String get loginFailedPleaseTryAgain {
    return Intl.message(
      'Login failed. Please try again.',
      name: 'loginFailedPleaseTryAgain',
      desc: '',
      args: [],
    );
  }

  /// `Something went wrong with the web page.`
  String get someThingWithWrongWithTheWebPage {
    return Intl.message(
      'Something went wrong with the web page.',
      name: 'someThingWithWrongWithTheWebPage',
      desc: '',
      args: [],
    );
  }

  /// `Loading OTP settings...`
  String get loadingOtpSetting {
    return Intl.message(
      'Loading OTP settings...',
      name: 'loadingOtpSetting',
      desc: '',
      args: [],
    );
  }

  /// `You can now resend the OTP.`
  String get youCanNowResendYourOtp {
    return Intl.message(
      'You can now resend the OTP.',
      name: 'youCanNowResendYourOtp',
      desc: '',
      args: [],
    );
  }

  /// `Resend OTP in ${start} seconds`
  String resendOtpSeconds(Object start) {
    return Intl.message(
      'Resend OTP in \$$start seconds',
      name: 'resendOtpSeconds',
      desc: '',
      args: [start],
    );
  }

  /// `Old Password`
  String get oldPassword {
    return Intl.message(
      'Old Password',
      name: 'oldPassword',
      desc: '',
      args: [],
    );
  }

  /// `Old Password can't be empty`
  String get oldPasswordCanNotBeEmpty {
    return Intl.message(
      'Old Password can\'t be empty',
      name: 'oldPasswordCanNotBeEmpty',
      desc: '',
      args: [],
    );
  }

  /// `seconds`
  String get seconds {
    return Intl.message('seconds', name: 'seconds', desc: '', args: []);
  }

  /// `Downloading...`
  String get downloading {
    return Intl.message(
      'Downloading...',
      name: 'downloading',
      desc: '',
      args: [],
    );
  }

  /// `Download successful! Check your Documents folder`
  String get downloadSuccessfulPleaseCheckYourDocumentFolder {
    return Intl.message(
      'Download successful! Check your Documents folder',
      name: 'downloadSuccessfulPleaseCheckYourDocumentFolder',
      desc: '',
      args: [],
    );
  }

  /// `Print Barcode`
  String get printBarCode {
    return Intl.message(
      'Print Barcode',
      name: 'printBarCode',
      desc: '',
      args: [],
    );
  }

  /// `You do not have permission to generate barcode.`
  String get youDoNotHavePermissionToGenerateBarcode {
    return Intl.message(
      'You do not have permission to generate barcode.',
      name: 'youDoNotHavePermissionToGenerateBarcode',
      desc: '',
      args: [],
    );
  }

  /// `Download`
  String get download {
    return Intl.message('Download', name: 'download', desc: '', args: []);
  }

  /// `Packing Date`
  String get packingDate {
    return Intl.message(
      'Packing Date',
      name: 'packingDate',
      desc: '',
      args: [],
    );
  }

  /// `Permission denied to View bank.`
  String get permissionDeniedToViewBank {
    return Intl.message(
      'Permission denied to View bank.',
      name: 'permissionDeniedToViewBank',
      desc: '',
      args: [],
    );
  }

  /// `Permission denied to update bank.`
  String get permissionDeniedToUpdateBank {
    return Intl.message(
      'Permission denied to update bank.',
      name: 'permissionDeniedToUpdateBank',
      desc: '',
      args: [],
    );
  }

  /// `Edit Warehouse`
  String get editWarehouse {
    return Intl.message(
      'Edit Warehouse',
      name: 'editWarehouse',
      desc: '',
      args: [],
    );
  }

  /// `Add New Warehouse`
  String get addNewWarehouse {
    return Intl.message(
      'Add New Warehouse',
      name: 'addNewWarehouse',
      desc: '',
      args: [],
    );
  }

  /// `Warehouse Name`
  String get warehouseName {
    return Intl.message(
      'Warehouse Name',
      name: 'warehouseName',
      desc: '',
      args: [],
    );
  }

  /// `Enter warehouse name`
  String get enterWarehouseName {
    return Intl.message(
      'Enter warehouse name',
      name: 'enterWarehouseName',
      desc: '',
      args: [],
    );
  }

  /// `Amount must be greater than 0`
  String get amountMustBeGreaterThanZero {
    return Intl.message(
      'Amount must be greater than 0',
      name: 'amountMustBeGreaterThanZero',
      desc: '',
      args: [],
    );
  }

  /// `Could not retrieve payment details.`
  String get canNotRetrievePaymentDetails {
    return Intl.message(
      'Could not retrieve payment details.',
      name: 'canNotRetrievePaymentDetails',
      desc: '',
      args: [],
    );
  }

  /// `You do not have permission to create expense.`
  String get youDonNotHavePermissionToCreateExpense {
    return Intl.message(
      'You do not have permission to create expense.',
      name: 'youDonNotHavePermissionToCreateExpense',
      desc: '',
      args: [],
    );
  }

  /// `You do not have permission to create expense category.`
  String get youDoNotHavePermissionToCreateExpenseCategory {
    return Intl.message(
      'You do not have permission to create expense category.',
      name: 'youDoNotHavePermissionToCreateExpenseCategory',
      desc: '',
      args: [],
    );
  }

  /// `You do not have permission to create income.`
  String get youDonNotHavePermissionToCreateIncome {
    return Intl.message(
      'You do not have permission to create income.',
      name: 'youDonNotHavePermissionToCreateIncome',
      desc: '',
      args: [],
    );
  }

  /// `You do not have permission to create income category.`
  String get youDoNotHavePermissionToCreateIncomeCategory {
    return Intl.message(
      'You do not have permission to create income category.',
      name: 'youDoNotHavePermissionToCreateIncomeCategory',
      desc: '',
      args: [],
    );
  }

  /// `Sales Return`
  String get salesReturn {
    return Intl.message(
      'Sales Return',
      name: 'salesReturn',
      desc: '',
      args: [],
    );
  }

  /// `Sales Return`
  String get purchaseReturn {
    return Intl.message(
      'Purchase Return',
      name: 'purchaseReturn',
      desc: '',
      args: [],
    );
  }

  /// `Return Quantity`
  String get returnQuantity {
    return Intl.message(
      'Return Quantity',
      name: 'returnQuantity',
      desc: '',
      args: [],
    );
  }

  /// `Non Refundable(VAT/Discount)`
  String get nonFoundableDiscount {
    return Intl.message(
      'Non Refundable(VAT/Discount)',
      name: 'nonFoundableDiscount',
      desc: '',
      args: [],
    );
  }

  /// `Confirm return`
  String get confirmReturn {
    return Intl.message(
      'Confirm return',
      name: 'confirmReturn',
      desc: '',
      args: [],
    );
  }

  /// `Please select product for return`
  String get pleaseSelectForProductReturn {
    return Intl.message(
      'Please select product for return',
      name: 'pleaseSelectForProductReturn',
      desc: '',
      args: [],
    );
  }

  /// `Failed to process return.`
  String get failedToProcessReturn {
    return Intl.message(
      'Failed to process return.',
      name: 'failedToProcessReturn',
      desc: '',
      args: [],
    );
  }

  /// `No values defined`
  String get noValuesDenied {
    return Intl.message(
      'No values defined',
      name: 'noValuesDenied',
      desc: '',
      args: [],
    );
  }

  /// `Edit Category`
  String get editCategory {
    return Intl.message(
      'Edit Category',
      name: 'editCategory',
      desc: '',
      args: [],
    );
  }

  /// `Edit Model`
  String get editModel {
    return Intl.message('Edit Model', name: 'editModel', desc: '', args: []);
  }

  /// `Add New Model`
  String get addNewModel {
    return Intl.message(
      'Add New Model',
      name: 'addNewModel',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid name`
  String get pleaseEnterValidName {
    return Intl.message(
      'Please enter a valid name',
      name: 'pleaseEnterValidName',
      desc: '',
      args: [],
    );
  }

  /// `Model Name`
  String get modelName {
    return Intl.message('Model Name', name: 'modelName', desc: '', args: []);
  }

  /// `Enter Model Name`
  String get enterModelName {
    return Intl.message(
      'Enter Model Name',
      name: 'enterModelName',
      desc: '',
      args: [],
    );
  }

  /// `You do not have permission to create model`
  String get youDoNotHavePermissionToCreateModel {
    return Intl.message(
      'You do not have permission to create model',
      name: 'youDoNotHavePermissionToCreateModel',
      desc: '',
      args: [],
    );
  }

  /// `You do not have permission to update model`
  String get youDoNotHavePermissionToUpdateModel {
    return Intl.message(
      'You do not have permission to update model',
      name: 'youDoNotHavePermissionToUpdateModel',
      desc: '',
      args: [],
    );
  }

  /// `Model Updated Successfully!`
  String get modelUpdateSuccessfully {
    return Intl.message(
      'Model Updated Successfully!',
      name: 'modelUpdateSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Model Created Successfully!`
  String get modelCreatedSuccessfully {
    return Intl.message(
      'Model Created Successfully!',
      name: 'modelCreatedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Models`
  String get models {
    return Intl.message('Models', name: 'models', desc: '', args: []);
  }

  /// `You do not have permission to delete model.`
  String get youDoNotHavePermissionDeleteModel {
    return Intl.message(
      'You do not have permission to delete model.',
      name: 'youDoNotHavePermissionDeleteModel',
      desc: '',
      args: [],
    );
  }

  /// `Enter label text`
  String get enterLabelText {
    return Intl.message(
      'Enter label text',
      name: 'enterLabelText',
      desc: '',
      args: [],
    );
  }

  /// `Search Batch no...`
  String get searchBatchNo {
    return Intl.message(
      'Search Batch no...',
      name: 'searchBatchNo',
      desc: '',
      args: [],
    );
  }

  /// `Not Active User`
  String get noActiveUser {
    return Intl.message(
      'Not Active User',
      name: 'noActiveUser',
      desc: '',
      args: [],
    );
  }

  /// `Please use the valid purchase code to use the app.`
  String get pleaseUseValidPurchaseCodeUseTheApp {
    return Intl.message(
      'Please use the valid purchase code to use the app.',
      name: 'pleaseUseValidPurchaseCodeUseTheApp',
      desc: '',
      args: [],
    );
  }

  /// `No Internet Connection`
  String get notInternetConnection {
    return Intl.message(
      'No Internet Connection',
      name: 'notInternetConnection',
      desc: '',
      args: [],
    );
  }

  /// `Please check your internet connection and try again`
  String get pleaseCheckYourInternetConnection {
    return Intl.message(
      'Please check your internet connection and try again',
      name: 'pleaseCheckYourInternetConnection',
      desc: '',
      args: [],
    );
  }

  /// `Ok`
  String get ok {
    return Intl.message('Ok', name: 'ok', desc: '', args: []);
  }

  /// `Add Cash`
  String get addCash {
    return Intl.message('Add Cash', name: 'addCash', desc: '', args: []);
  }

  /// `Reduce Cash`
  String get reduceCash {
    return Intl.message('Reduce Cash', name: 'reduceCash', desc: '', args: []);
  }

  /// `Transaction Type`
  String get transactionType {
    return Intl.message(
      'Transaction Type',
      name: 'transactionType',
      desc: '',
      args: [],
    );
  }

  /// `User`
  String get user {
    return Intl.message('User', name: 'user', desc: '', args: []);
  }

  /// `To Account`
  String get toAccount {
    return Intl.message('To Account', name: 'toAccount', desc: '', args: []);
  }

  /// `From Account`
  String get fromAccount {
    return Intl.message(
      'From Account',
      name: 'fromAccount',
      desc: '',
      args: [],
    );
  }

  /// `Years`
  String get years {
    return Intl.message('Years', name: 'years', desc: '', args: []);
  }

  /// `Combo Product Report`
  String get comboProductReport {
    return Intl.message(
      'Combo Product Report',
      name: 'comboProductReport',
      desc: '',
      args: [],
    );
  }

  /// `Gross Profit`
  String get grossProfit {
    return Intl.message(
      'Gross Profit',
      name: 'grossProfit',
      desc: '',
      args: [],
    );
  }

  /// `Net Profit`
  String get netProfit {
    return Intl.message('Net Profit', name: 'netProfit', desc: '', args: []);
  }

  /// `Income Type`
  String get incomeType {
    return Intl.message('Income Type', name: 'incomeType', desc: '', args: []);
  }

  /// `Ledger`
  String get ledger {
    return Intl.message('Ledger', name: 'ledger', desc: '', args: []);
  }

  /// `Expenses Types`
  String get expensesType {
    return Intl.message(
      'Expenses Types',
      name: 'expensesType',
      desc: '',
      args: [],
    );
  }

  /// `Reset`
  String get resets {
    return Intl.message('Reset', name: 'resets', desc: '', args: []);
  }

  /// `Package Name`
  String get packageName {
    return Intl.message(
      'Package Name',
      name: 'packageName',
      desc: '',
      args: [],
    );
  }

  /// `Start`
  String get start {
    return Intl.message('Start', name: 'start', desc: '', args: []);
  }

  /// `Payment Method`
  String get paymentMethod {
    return Intl.message(
      'Payment Method',
      name: 'paymentMethod',
      desc: '',
      args: [],
    );
  }

  /// `Add Payment`
  String get addPayment {
    return Intl.message('Add Payment', name: 'addPayment', desc: '', args: []);
  }

  /// `Advance`
  String get advance {
    return Intl.message('Advance', name: 'advance', desc: '', args: []);
  }

  /// `Note Level`
  String get noteLevel {
    return Intl.message('Note Level', name: 'noteLevel', desc: '', args: []);
  }

  /// `Enter Your Note Level`
  String get enterYourNoteLevel {
    return Intl.message(
      'Enter Your Note Level',
      name: 'enterYourNoteLevel',
      desc: '',
      args: [],
    );
  }

  /// `Post Sale Message`
  String get postSaleMessage {
    return Intl.message(
      'Post Sale Message',
      name: 'postSaleMessage',
      desc: '',
      args: [],
    );
  }

  /// `Enter your Post Sale Message`
  String get enterYourPostSaleMessage {
    return Intl.message(
      'Enter your Post Sale Message',
      name: 'enterYourPostSaleMessage',
      desc: '',
      args: [],
    );
  }

  /// `A4 Page Invoice Logo`
  String get a4PageLogo {
    return Intl.message(
      'A4 Page Invoice Logo',
      name: 'a4PageLogo',
      desc: '',
      args: [],
    );
  }

  /// `Thermal Invoice Invoice Logo`
  String get thermalInvoicePageLogo {
    return Intl.message(
      'Thermal Invoice Invoice Logo',
      name: 'thermalInvoicePageLogo',
      desc: '',
      args: [],
    );
  }

  /// `Thermal Printer Language`
  String get thermalPrinterLanguage {
    return Intl.message(
      'Thermal Printer Language',
      name: 'thermalPrinterLanguage',
      desc: '',
      args: [],
    );
  }

  /// `Thermal Printer Page Size`
  String get thermalPrinterPageSize {
    return Intl.message(
      'Thermal Printer Page Size',
      name: 'thermalPrinterPageSize',
      desc: '',
      args: [],
    );
  }

  /// `Open Setting`
  String get openSetting {
    return Intl.message(
      'Open Setting',
      name: 'openSetting',
      desc: '',
      args: [],
    );
  }

  /// `Select Rack`
  String get selectRack {
    return Intl.message('Select Rack', name: 'selectRack', desc: '', args: []);
  }

  /// `Rack`
  String get rack {
    return Intl.message('Rack', name: 'rack', desc: '', args: []);
  }

  /// `Select Shelf`
  String get selectShelf {
    return Intl.message(
      'Select Shelf',
      name: 'selectShelf',
      desc: '',
      args: [],
    );
  }

  /// `Shelf`
  String get shelf {
    return Intl.message('Shelf', name: 'shelf', desc: '', args: []);
  }

  /// `Variations`
  String get variations {
    return Intl.message('Variations', name: 'variations', desc: '', args: []);
  }

  /// `Combo`
  String get combo {
    return Intl.message('Combo', name: 'combo', desc: '', args: []);
  }

  /// `Enter Batch No.`
  String get enterBatchNo {
    return Intl.message(
      'Enter Batch No.',
      name: 'enterBatchNo',
      desc: '',
      args: [],
    );
  }

  /// `Select Warehouse`
  String get selectWarehouse {
    return Intl.message(
      'Select Warehouse',
      name: 'selectWarehouse',
      desc: '',
      args: [],
    );
  }

  /// `Warehouse`
  String get warehouse {
    return Intl.message('Warehouse', name: 'warehouse', desc: '', args: []);
  }

  /// `Net Total Amount`
  String get netTotalAmount {
    return Intl.message(
      'Net Total Amount',
      name: 'netTotalAmount',
      desc: '',
      args: [],
    );
  }

  /// `Default Selling Price`
  String get defaultSellingPrice {
    return Intl.message(
      'Default Selling Price',
      name: 'defaultSellingPrice',
      desc: '',
      args: [],
    );
  }

  /// `Select Items`
  String get selectItems {
    return Intl.message(
      'Select Items',
      name: 'selectItems',
      desc: '',
      args: [],
    );
  }

  /// `Variant List`
  String get variantList {
    return Intl.message(
      'Variant List',
      name: 'variantList',
      desc: '',
      args: [],
    );
  }

  /// `Add Sub-Variation`
  String get addSubVariation {
    return Intl.message(
      'Add Sub-Variation',
      name: 'addSubVariation',
      desc: '',
      args: [],
    );
  }

  /// `Edit Product`
  String get editProduct {
    return Intl.message(
      'Edit Product',
      name: 'editProduct',
      desc: '',
      args: [],
    );
  }

  /// `No Item Found`
  String get noItemFound {
    return Intl.message(
      'No Item Found',
      name: 'noItemFound',
      desc: '',
      args: [],
    );
  }

  /// `You do not have permission to delete shelf`
  String get youDoNotHavePermissionDeleteTheShelf {
    return Intl.message(
      'You do not have permission to delete shelf',
      name: 'youDoNotHavePermissionDeleteTheShelf',
      desc: '',
      args: [],
    );
  }

  /// `No matching results found`
  String get notMatchingResultFound {
    return Intl.message(
      'No matching results found',
      name: 'notMatchingResultFound',
      desc: '',
      args: [],
    );
  }

  /// `Edit Shelf`
  String get editShelf {
    return Intl.message('Edit Shelf', name: 'editShelf', desc: '', args: []);
  }

  /// `Add New Shelf`
  String get addShelf {
    return Intl.message('Add New Shelf', name: 'addShelf', desc: '', args: []);
  }

  /// `Shelf Name`
  String get shelfName {
    return Intl.message('Shelf Name', name: 'shelfName', desc: '', args: []);
  }

  /// `Enter Shelf Name`
  String get enterShelfName {
    return Intl.message(
      'Enter Shelf Name',
      name: 'enterShelfName',
      desc: '',
      args: [],
    );
  }

  /// `Please enter shelf name`
  String get pleaseEnterShelfName {
    return Intl.message(
      'Please enter shelf name',
      name: 'pleaseEnterShelfName',
      desc: '',
      args: [],
    );
  }

  /// `Product Racks`
  String get productRacks {
    return Intl.message(
      'Product Racks',
      name: 'productRacks',
      desc: '',
      args: [],
    );
  }

  /// `Racks`
  String get racks {
    return Intl.message('Racks', name: 'racks', desc: '', args: []);
  }

  /// `You do not have permission to create racks.`
  String get youDoNtHavePermissionToCreateRacks {
    return Intl.message(
      'You do not have permission to create racks.',
      name: 'youDoNtHavePermissionToCreateRacks',
      desc: '',
      args: [],
    );
  }

  /// `You do not have permission to delete racks.`
  String get youDoNtHavePermissionToDeleteRacks {
    return Intl.message(
      'You do not have permission to delete racks.',
      name: 'youDoNtHavePermissionToDeleteRacks',
      desc: '',
      args: [],
    );
  }

  /// `You do not have permission to update racks.`
  String get youDoNtHavePermissionToUpdateRacks {
    return Intl.message(
      'You do not have permission to update racks.',
      name: 'youDoNtHavePermissionToUpdateRacks',
      desc: '',
      args: [],
    );
  }

  /// `Add New Rack`
  String get addNewRack {
    return Intl.message('Add New Rack', name: 'addNewRack', desc: '', args: []);
  }

  /// `Edit Rack`
  String get editRack {
    return Intl.message('Edit Rack', name: 'editRack', desc: '', args: []);
  }

  /// `Rack Name`
  String get rackName {
    return Intl.message('Rack Name', name: 'rackName', desc: '', args: []);
  }

  /// `Please enter rack name`
  String get pleaseEnterRackName {
    return Intl.message(
      'Please enter rack name',
      name: 'pleaseEnterRackName',
      desc: '',
      args: [],
    );
  }

  /// `Shelves`
  String get shelves {
    return Intl.message('Shelves', name: 'shelves', desc: '', args: []);
  }

  /// `Press to select`
  String get pressToSelect {
    return Intl.message(
      'Press to select',
      name: 'pressToSelect',
      desc: '',
      args: [],
    );
  }

  /// `Select at least one shelf`
  String get selectAtLeastOneRack {
    return Intl.message(
      'Select at least one shelf',
      name: 'selectAtLeastOneRack',
      desc: '',
      args: [],
    );
  }

  /// `InActive`
  String get inActive {
    return Intl.message('InActive', name: 'inActive', desc: '', args: []);
  }

  /// `Add New Variation`
  String get addNewVariation {
    return Intl.message(
      'Add New Variation',
      name: 'addNewVariation',
      desc: '',
      args: [],
    );
  }

  /// `Edit Variation`
  String get editVariations {
    return Intl.message(
      'Edit Variation',
      name: 'editVariations',
      desc: '',
      args: [],
    );
  }

  /// `Values`
  String get values {
    return Intl.message('Values', name: 'values', desc: '', args: []);
  }

  /// `Enter values`
  String get enterValues {
    return Intl.message(
      'Enter values',
      name: 'enterValues',
      desc: '',
      args: [],
    );
  }

  /// `Please enter at least one value.`
  String get pleaseEnterAtLeastOneValues {
    return Intl.message(
      'Please enter at least one value.',
      name: 'pleaseEnterAtLeastOneValues',
      desc: '',
      args: [],
    );
  }

  /// `Product Variations`
  String get productVariations {
    return Intl.message(
      'Product Variations',
      name: 'productVariations',
      desc: '',
      args: [],
    );
  }

  /// `Permission Denied`
  String get permissionDenied {
    return Intl.message(
      'Permission Denied',
      name: 'permissionDenied',
      desc: '',
      args: [],
    );
  }

  /// `No variations found.`
  String get noVariationFound {
    return Intl.message(
      'No variations found.',
      name: 'noVariationFound',
      desc: '',
      args: [],
    );
  }

  /// `Add New Variation`
  String get addNewVariations {
    return Intl.message(
      'Add New Variation',
      name: 'addNewVariations',
      desc: '',
      args: [],
    );
  }

  /// `Variation ID`
  String get variationId {
    return Intl.message(
      'Variation ID',
      name: 'variationId',
      desc: '',
      args: [],
    );
  }

  /// `Update Role`
  String get updateRole {
    return Intl.message('Update Role', name: 'updateRole', desc: '', args: []);
  }

  /// `Add Role`
  String get addRole {
    return Intl.message('Add Role', name: 'addRole', desc: '', args: []);
  }

  /// `Enter user name`
  String get enterUserName {
    return Intl.message(
      'Enter user name',
      name: 'enterUserName',
      desc: '',
      args: [],
    );
  }

  /// `Enter your password`
  String get enterYourPassword {
    return Intl.message(
      'Enter your password',
      name: 'enterYourPassword',
      desc: '',
      args: [],
    );
  }

  /// `Select All`
  String get selectAll {
    return Intl.message('Select All', name: 'selectAll', desc: '', args: []);
  }

  /// `S.No.`
  String get sNo {
    return Intl.message('S.No.', name: 'sNo', desc: '', args: []);
  }

  /// `Feature`
  String get feature {
    return Intl.message('Feature', name: 'feature', desc: '', args: []);
  }

  /// `Read`
  String get read {
    return Intl.message('Read', name: 'read', desc: '', args: []);
  }

  /// `View Price`
  String get viewPrice {
    return Intl.message('View Price', name: 'viewPrice', desc: '', args: []);
  }

  /// `Purchase Returns`
  String get purchaseReturns {
    return Intl.message(
      'Purchase Returns',
      name: 'purchaseReturns',
      desc: '',
      args: [],
    );
  }

  /// `Expired Products`
  String get expiredProduct {
    return Intl.message(
      'Expired Products',
      name: 'expiredProduct',
      desc: '',
      args: [],
    );
  }

  /// `Barcodes`
  String get barcodes {
    return Intl.message('Barcodes', name: 'barcodes', desc: '', args: []);
  }

  /// `Bulk Uploads`
  String get bulkUploads {
    return Intl.message(
      'Bulk Uploads',
      name: 'bulkUploads',
      desc: '',
      args: [],
    );
  }

  /// `Product Models`
  String get productModels {
    return Intl.message(
      'Product Models',
      name: 'productModels',
      desc: '',
      args: [],
    );
  }

  /// `Income`
  String get incomes {
    return Intl.message('Income', name: 'incomes', desc: '', args: []);
  }

  /// `Dues`
  String get dues {
    return Intl.message('Dues', name: 'dues', desc: '', args: []);
  }

  /// `Subscriptions`
  String get subscriptions {
    return Intl.message(
      'Subscriptions',
      name: 'subscriptions',
      desc: '',
      args: [],
    );
  }

  /// `Payments Types`
  String get paymentsTypes {
    return Intl.message(
      'Payments Types',
      name: 'paymentsTypes',
      desc: '',
      args: [],
    );
  }

  /// `Roles`
  String get roles {
    return Intl.message('Roles', name: 'roles', desc: '', args: []);
  }

  /// `Manage Settings`
  String get manageSetting {
    return Intl.message(
      'Manage Settings',
      name: 'manageSetting',
      desc: '',
      args: [],
    );
  }

  /// `Download APK`
  String get downloadApk {
    return Intl.message(
      'Download APK',
      name: 'downloadApk',
      desc: '',
      args: [],
    );
  }

  /// `Vat Reports`
  String get vatReports {
    return Intl.message('Vat Reports', name: 'vatReports', desc: '', args: []);
  }

  /// `Prfot & Loss Details Report`
  String get profitAndLossDetailsReport {
    return Intl.message(
      'Prfot & Loss Details Report',
      name: 'profitAndLossDetailsReport',
      desc: '',
      args: [],
    );
  }

  /// `Transaction History Reports`
  String get transactionsHistoryReport {
    return Intl.message(
      'Transaction History Reports',
      name: 'transactionsHistoryReport',
      desc: '',
      args: [],
    );
  }

  /// `Expire Product Reports`
  String get expireProductReports {
    return Intl.message(
      'Expire Product Reports',
      name: 'expireProductReports',
      desc: '',
      args: [],
    );
  }

  /// `Product purchase report`
  String get productPurchaseReport {
    return Intl.message(
      'Product purchase report',
      name: 'productPurchaseReport',
      desc: '',
      args: [],
    );
  }

  /// `Product sales report`
  String get productSalesReport {
    return Intl.message(
      'Product sales report',
      name: 'productSalesReport',
      desc: '',
      args: [],
    );
  }

  /// `Role`
  String get role {
    return Intl.message('Role', name: 'role', desc: '', args: []);
  }

  /// `Are you sure you want to delete this Role?`
  String get areYouSureWantToDeleteThisRole {
    return Intl.message(
      'Are you sure you want to delete this Role?',
      name: 'areYouSureWantToDeleteThisRole',
      desc: '',
      args: [],
    );
  }

  /// `In Stock`
  String get inStock {
    return Intl.message('In Stock', name: 'inStock', desc: '', args: []);
  }

  /// `Information to show in labels`
  String get informationShowInLabels {
    return Intl.message(
      'Information to show in labels',
      name: 'informationShowInLabels',
      desc: '',
      args: [],
    );
  }

  /// `Package Date`
  String get packageDate {
    return Intl.message(
      'Package Date',
      name: 'packageDate',
      desc: '',
      args: [],
    );
  }

  /// `Barcode print label setting`
  String get barCodePrintLabelSetting {
    return Intl.message(
      'Barcode print label setting',
      name: 'barCodePrintLabelSetting',
      desc: '',
      args: [],
    );
  }

  /// `Labels Roll-Label Size 2"*1, 50mm*25mm, Gap 3.1mm`
  String get labelRoleLabelSize2Inch {
    return Intl.message(
      'Labels Roll-Label Size 2"*1, 50mm*25mm, Gap 3.1mm',
      name: 'labelRoleLabelSize2Inch',
      desc: '',
      args: [],
    );
  }

  /// `Labels Roll-Label Size 1.5"*1, 38mm*25mm, Gap 3.1mm`
  String get labelRoleLabelSize1_5Inch {
    return Intl.message(
      'Labels Roll-Label Size 1.5"*1, 38mm*25mm, Gap 3.1mm',
      name: 'labelRoleLabelSize1_5Inch',
      desc: '',
      args: [],
    );
  }

  /// `32 Labels Per Sheet, 8.27 inches by 11.69 inches`
  String get thirtyTwoLabelPerSheet {
    return Intl.message(
      '32 Labels Per Sheet, 8.27 inches by 11.69 inches',
      name: 'thirtyTwoLabelPerSheet',
      desc: '',
      args: [],
    );
  }

  /// `You do not have permission to generate barcode.`
  String get youDoNotHaveAnyPermissionToGenerateBarCode {
    return Intl.message(
      'You do not have permission to generate barcode.',
      name: 'youDoNotHaveAnyPermissionToGenerateBarCode',
      desc: '',
      args: [],
    );
  }

  /// `Please select a product first`
  String get pleaseSelectAProductFirst {
    return Intl.message(
      'Please select a product first',
      name: 'pleaseSelectAProductFirst',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid quantity (at least 1) for all products`
  String get pleaseEnterAValidQuantity {
    return Intl.message(
      'Please enter a valid quantity (at least 1) for all products',
      name: 'pleaseEnterAValidQuantity',
      desc: '',
      args: [],
    );
  }

  /// `Please select a product first`
  String get pleaseSelectProductFirst {
    return Intl.message(
      'Please select a product first',
      name: 'pleaseSelectProductFirst',
      desc: '',
      args: [],
    );
  }

  /// `Bluetooth is turned off. Please turn it on.`
  String get bluetoothIsTurnedOff {
    return Intl.message(
      'Bluetooth is turned off. Please turn it on.',
      name: 'bluetoothIsTurnedOff',
      desc: '',
      args: [],
    );
  }

  /// `No Bluetooth device selected.`
  String get noBluetoothDeviceSelected {
    return Intl.message(
      'No Bluetooth device selected.',
      name: 'noBluetoothDeviceSelected',
      desc: '',
      args: [],
    );
  }

  /// `Print Label`
  String get printLabel {
    return Intl.message('Print Label', name: 'printLabel', desc: '', args: []);
  }

  /// `Scanning for devices...`
  String get caningForDevices {
    return Intl.message(
      'Scanning for devices...',
      name: 'caningForDevices',
      desc: '',
      args: [],
    );
  }

  /// `No Devices Found`
  String get noDeviceFound {
    return Intl.message(
      'No Devices Found',
      name: 'noDeviceFound',
      desc: '',
      args: [],
    );
  }

  /// `Retry Scan`
  String get retryScan {
    return Intl.message('Retry Scan', name: 'retryScan', desc: '', args: []);
  }

  /// `Connected to`
  String get connectedTo {
    return Intl.message(
      'Connected to',
      name: 'connectedTo',
      desc: '',
      args: [],
    );
  }

  /// `Please enable Bluetooth`
  String get pleaseEnableBluetooth {
    return Intl.message(
      'Please enable Bluetooth',
      name: 'pleaseEnableBluetooth',
      desc: '',
      args: [],
    );
  }

  /// `SKU / Code`
  String get skuOrCode {
    return Intl.message('SKU / Code', name: 'skuOrCode', desc: '', args: []);
  }

  /// `Low Stock Alert`
  String get lowStockAlert {
    return Intl.message(
      'Low Stock Alert',
      name: 'lowStockAlert',
      desc: '',
      args: [],
    );
  }

  /// `Tax`
  String get tax {
    return Intl.message('Tax', name: 'tax', desc: '', args: []);
  }

  /// `Cost exc. tax`
  String get costExclusionTax {
    return Intl.message(
      'Cost exc. tax',
      name: 'costExclusionTax',
      desc: '',
      args: [],
    );
  }

  /// `Cost inc. tax`
  String get costInclusionTax {
    return Intl.message(
      'Cost inc. tax',
      name: 'costInclusionTax',
      desc: '',
      args: [],
    );
  }

  /// `MRP/Sales Price`
  String get mrpOrSalePrice {
    return Intl.message(
      'MRP/Sales Price',
      name: 'mrpOrSalePrice',
      desc: '',
      args: [],
    );
  }

  /// `Expire Date`
  String get expiredDate {
    return Intl.message('Expire Date', name: 'expiredDate', desc: '', args: []);
  }

  /// `Selling Price`
  String get sellingPrice {
    return Intl.message(
      'Selling Price',
      name: 'sellingPrice',
      desc: '',
      args: [],
    );
  }

  /// `Variation Products`
  String get variationsProduct {
    return Intl.message(
      'Variation Products',
      name: 'variationsProduct',
      desc: '',
      args: [],
    );
  }

  /// `Combo Products`
  String get comboProducts {
    return Intl.message(
      'Combo Products',
      name: 'comboProducts',
      desc: '',
      args: [],
    );
  }

  /// `No stock data available.`
  String get noStockAvailable {
    return Intl.message(
      'No stock data available.',
      name: 'noStockAvailable',
      desc: '',
      args: [],
    );
  }

  /// `High to Low Price`
  String get highToLowPrice {
    return Intl.message(
      'High to Low Price',
      name: 'highToLowPrice',
      desc: '',
      args: [],
    );
  }

  /// `Low to high Price`
  String get lowToHighPrice {
    return Intl.message(
      'Low to high Price',
      name: 'lowToHighPrice',
      desc: '',
      args: [],
    );
  }

  /// `Attachment`
  String get attachment {
    return Intl.message('Attachment', name: 'attachment', desc: '', args: []);
  }

  /// `View Stock`
  String get viewStock {
    return Intl.message('View Stock', name: 'viewStock', desc: '', args: []);
  }

  /// `Expiry`
  String get expiry {
    return Intl.message('Expiry', name: 'expiry', desc: '', args: []);
  }

  /// `Expire`
  String get expire {
    return Intl.message('Expire', name: 'expire', desc: '', args: []);
  }

  /// `7 Days`
  String get sevenDays {
    return Intl.message('7 Days', name: 'sevenDays', desc: '', args: []);
  }

  /// `15 Days`
  String get fifteenthDays {
    return Intl.message('15 Days', name: 'fifteenthDays', desc: '', args: []);
  }

  /// `30 Days`
  String get thirtyDays {
    return Intl.message('30 Days', name: 'thirtyDays', desc: '', args: []);
  }

  /// `60 Days`
  String get sixtyDays {
    return Intl.message('60 Days', name: 'sixtyDays', desc: '', args: []);
  }

  /// `Our premium Plan`
  String get outPremiumPlan {
    return Intl.message(
      'Our premium Plan',
      name: 'outPremiumPlan',
      desc: '',
      args: [],
    );
  }

  /// `You do not have permission to create purchases.`
  String get youDoNotHavePermissionToCreatePurchase {
    return Intl.message(
      'You do not have permission to create purchases.',
      name: 'youDoNotHavePermissionToCreatePurchase',
      desc: '',
      args: [],
    );
  }

  /// `This plan is not available for purchase`
  String get thisPlanIsNotAvailableToPurchase {
    return Intl.message(
      'This plan is not available for purchase',
      name: 'thisPlanIsNotAvailableToPurchase',
      desc: '',
      args: [],
    );
  }

  /// `This plan is not eligible for upgrade`
  String get thisPlanIsEligibleForUpgrade {
    return Intl.message(
      'This plan is not eligible for upgrade',
      name: 'thisPlanIsEligibleForUpgrade',
      desc: '',
      args: [],
    );
  }

  /// `Extend Plan`
  String get extendPlan {
    return Intl.message('Extend Plan', name: 'extendPlan', desc: '', args: []);
  }

  /// `Buy Now`
  String get buyNow {
    return Intl.message('Buy Now', name: 'buyNow', desc: '', args: []);
  }

  /// `None`
  String get none {
    return Intl.message('None', name: 'none', desc: '', args: []);
  }

  /// `Round to whole number`
  String get roundToWholeNumber {
    return Intl.message(
      'Round to whole number',
      name: 'roundToWholeNumber',
      desc: '',
      args: [],
    );
  }

  /// `Round to nearest whole number`
  String get roundToNearestWholeNumber {
    return Intl.message(
      'Round to nearest whole number',
      name: 'roundToNearestWholeNumber',
      desc: '',
      args: [],
    );
  }

  /// `Round to nearest decimal (0.05)`
  String get roundToNearnessDecimalNumber005 {
    return Intl.message(
      'Round to nearest decimal (0.05)',
      name: 'roundToNearnessDecimalNumber005',
      desc: '',
      args: [],
    );
  }

  /// `Round to nearest decimal (0.1)`
  String get roundToNearnessDecimalNumber01 {
    return Intl.message(
      'Round to nearest decimal (0.1)',
      name: 'roundToNearnessDecimalNumber01',
      desc: '',
      args: [],
    );
  }

  /// `Round to nearest decimal (0.5)`
  String get roundToNearnessDecimalNumber05 {
    return Intl.message(
      'Round to nearest decimal (0.5)',
      name: 'roundToNearnessDecimalNumber05',
      desc: '',
      args: [],
    );
  }

  /// `Last Year`
  String get lastYear {
    return Intl.message('Last Year', name: 'lastYear', desc: '', args: []);
  }

  /// `Product Stock`
  String get productStock {
    return Intl.message(
      'Product Stock',
      name: 'productStock',
      desc: '',
      args: [],
    );
  }

  /// `Unit`
  String get unit {
    return Intl.message('Unit', name: 'unit', desc: '', args: []);
  }

  /// `Show Expire Date`
  String get showExpireDate {
    return Intl.message(
      'Show Expire Date',
      name: 'showExpireDate',
      desc: '',
      args: [],
    );
  }

  /// `Vat Id`
  String get vatId {
    return Intl.message('Vat Id', name: 'vatId', desc: '', args: []);
  }

  /// `vatType`
  String get vatType {
    return Intl.message('vatType', name: 'vatType', desc: '', args: []);
  }

  /// `exclusivePrice`
  String get exclusivePrice {
    return Intl.message(
      'exclusivePrice',
      name: 'exclusivePrice',
      desc: '',
      args: [],
    );
  }

  /// `inclusivePrice`
  String get inclusivePrice {
    return Intl.message(
      'inclusivePrice',
      name: 'inclusivePrice',
      desc: '',
      args: [],
    );
  }

  /// `Profit Percent`
  String get profitPercent {
    return Intl.message(
      'Profit Percent',
      name: 'profitPercent',
      desc: '',
      args: [],
    );
  }

  /// `Show Single`
  String get showSingle {
    return Intl.message('Show Single', name: 'showSingle', desc: '', args: []);
  }

  /// `Show Combo`
  String get showCombo {
    return Intl.message('Show Combo', name: 'showCombo', desc: '', args: []);
  }

  /// `Show Variant`
  String get showVariant {
    return Intl.message(
      'Show Variant',
      name: 'showVariant',
      desc: '',
      args: [],
    );
  }

  /// `Show Action`
  String get showAction {
    return Intl.message('Show Action', name: 'showAction', desc: '', args: []);
  }

  /// `You do not have permission to generate report`
  String get youDoNotHavePermissionToGenerateReport {
    return Intl.message(
      'You do not have permission to generate report',
      name: 'youDoNotHavePermissionToGenerateReport',
      desc: '',
      args: [],
    );
  }

  /// `No data available`
  String get noDataAvailable {
    return Intl.message(
      'No data available',
      name: 'noDataAvailable',
      desc: '',
      args: [],
    );
  }

  /// `You do not have permission to export excel`
  String get youDoNotHavePermissionToExportExcel {
    return Intl.message(
      'You do not have permission to export excel',
      name: 'youDoNotHavePermissionToExportExcel',
      desc: '',
      args: [],
    );
  }

  /// `No data available for export`
  String get noDataAvailableForExport {
    return Intl.message(
      'No data available for export',
      name: 'noDataAvailableForExport',
      desc: '',
      args: [],
    );
  }

  /// `Supplier Due`
  String get supplierDue {
    return Intl.message(
      'Supplier Due',
      name: 'supplierDue',
      desc: '',
      args: [],
    );
  }

  /// `Party Type`
  String get partyType {
    return Intl.message('Party Type', name: 'partyType', desc: '', args: []);
  }

  /// `All Party`
  String get allParty {
    return Intl.message('All Party', name: 'allParty', desc: '', args: []);
  }

  /// `Yesterday`
  String get yesterday {
    return Intl.message('Yesterday', name: 'yesterday', desc: '', args: []);
  }

  /// `Last 7 Days`
  String get last7Days {
    return Intl.message('Last 7 Days', name: 'last7Days', desc: '', args: []);
  }

  /// `Last 30 Days`
  String get last30Days {
    return Intl.message('Last 30 Days', name: 'last30Days', desc: '', args: []);
  }

  /// `Current Month`
  String get currentMonth {
    return Intl.message(
      'Current Month',
      name: 'currentMonth',
      desc: '',
      args: [],
    );
  }

  /// `Last Month`
  String get lastMonth {
    return Intl.message('Last Month', name: 'lastMonth', desc: '', args: []);
  }

  /// `Current Year`
  String get currentYear {
    return Intl.message(
      'Current Year',
      name: 'currentYear',
      desc: '',
      args: [],
    );
  }

  /// `Custom Date`
  String get customerDate {
    return Intl.message(
      'Custom Date',
      name: 'customerDate',
      desc: '',
      args: [],
    );
  }

  /// `No transactions to generate PDF`
  String get noTransactionToGeneratePdf {
    return Intl.message(
      'No transactions to generate PDF',
      name: 'noTransactionToGeneratePdf',
      desc: '',
      args: [],
    );
  }

  /// `Generate Pdf`
  String get generatePdf {
    return Intl.message(
      'Generate Pdf',
      name: 'generatePdf',
      desc: '',
      args: [],
    );
  }

  /// `No transactions found`
  String get noTransactionFound {
    return Intl.message(
      'No transactions found',
      name: 'noTransactionFound',
      desc: '',
      args: [],
    );
  }

  /// `Reference`
  String get reference {
    return Intl.message('Reference', name: 'reference', desc: '', args: []);
  }

  /// `Credit (In)`
  String get creditIn {
    return Intl.message('Credit (In)', name: 'creditIn', desc: '', args: []);
  }

  /// `Debit (Out)`
  String get debitOut {
    return Intl.message('Debit (Out)', name: 'debitOut', desc: '', args: []);
  }

  /// `Subscribe Now`
  String get subscribeNow {
    return Intl.message(
      'Subscribe Now',
      name: 'subscribeNow',
      desc: '',
      args: [],
    );
  }

  /// `Expired`
  String get expired {
    return Intl.message('Expired', name: 'expired', desc: '', args: []);
  }

  /// `Total Balance`
  String get totalBalance {
    return Intl.message(
      'Total Balance',
      name: 'totalBalance',
      desc: '',
      args: [],
    );
  }

  /// `Hours Left`
  String get hoursLeft {
    return Intl.message('Hours Left', name: 'hoursLeft', desc: '', args: []);
  }

  /// `Days Left`
  String get daysLeft {
    return Intl.message('Days Left', name: 'daysLeft', desc: '', args: []);
  }

  /// `Pos`
  String get pos {
    return Intl.message('Pos', name: 'pos', desc: '', args: []);
  }

  /// `Profit & Loss`
  String get profitAndLoss {
    return Intl.message(
      'Profit & Loss',
      name: 'profitAndLoss',
      desc: '',
      args: [],
    );
  }

  /// `Branch`
  String get branch {
    return Intl.message('Branch', name: 'branch', desc: '', args: []);
  }

  /// `Hrm`
  String get hrm {
    return Intl.message('Hrm', name: 'hrm', desc: '', args: []);
  }

  /// `Inventory`
  String get inventory {
    return Intl.message('Inventory', name: 'inventory', desc: '', args: []);
  }

  /// `Edit Attendance`
  String get editAttendance {
    return Intl.message(
      'Edit Attendance',
      name: 'editAttendance',
      desc: '',
      args: [],
    );
  }

  /// `Add New Attendance`
  String get addNewAttendance {
    return Intl.message(
      'Add New Attendance',
      name: 'addNewAttendance',
      desc: '',
      args: [],
    );
  }

  /// `Employee`
  String get employee {
    return Intl.message('Employee', name: 'employee', desc: '', args: []);
  }

  /// `Please select an employee`
  String get pleaseSelectAnEmployee {
    return Intl.message(
      'Please select an employee',
      name: 'pleaseSelectAnEmployee',
      desc: '',
      args: [],
    );
  }

  /// `Shift`
  String get shift {
    return Intl.message('Shift', name: 'shift', desc: '', args: []);
  }

  /// `Select employee first`
  String get selectEmployeeFirst {
    return Intl.message(
      'Select employee first',
      name: 'selectEmployeeFirst',
      desc: '',
      args: [],
    );
  }

  /// `Select date first`
  String get selectDateFirst {
    return Intl.message(
      'Select date first',
      name: 'selectDateFirst',
      desc: '',
      args: [],
    );
  }

  /// `Month`
  String get month {
    return Intl.message('Month', name: 'month', desc: '', args: []);
  }

  /// `Auto-selected`
  String get autoSelected {
    return Intl.message(
      'Auto-selected',
      name: 'autoSelected',
      desc: '',
      args: [],
    );
  }

  /// `Please select date`
  String get pleaseSelectDate {
    return Intl.message(
      'Please select date',
      name: 'pleaseSelectDate',
      desc: '',
      args: [],
    );
  }

  /// `Time In`
  String get timeIn {
    return Intl.message('Time In', name: 'timeIn', desc: '', args: []);
  }

  /// `Time Out`
  String get timeOut {
    return Intl.message('Time Out', name: 'timeOut', desc: '', args: []);
  }

  /// `Attendance`
  String get attendance {
    return Intl.message('Attendance', name: 'attendance', desc: '', args: []);
  }

  /// `All Employee`
  String get allEmployee {
    return Intl.message(
      'All Employee',
      name: 'allEmployee',
      desc: '',
      args: [],
    );
  }

  /// `No attendance records found.`
  String get noAvailableRecordFound {
    return Intl.message(
      'No attendance records found.',
      name: 'noAvailableRecordFound',
      desc: '',
      args: [],
    );
  }

  /// `Add Attendance`
  String get addAttendance {
    return Intl.message(
      'Add Attendance',
      name: 'addAttendance',
      desc: '',
      args: [],
    );
  }

  /// `No note provided.`
  String get noNoteProvided {
    return Intl.message(
      'No note provided.',
      name: 'noNoteProvided',
      desc: '',
      args: [],
    );
  }

  /// `Duration`
  String get duration {
    return Intl.message('Duration', name: 'duration', desc: '', args: []);
  }

  /// `You do not have permission to view attendance`
  String get youDoNotHavePermissionToViewAttendance {
    return Intl.message(
      'You do not have permission to view attendance',
      name: 'youDoNotHavePermissionToViewAttendance',
      desc: '',
      args: [],
    );
  }

  /// `Department`
  String get department {
    return Intl.message('Department', name: 'department', desc: '', args: []);
  }

  /// `No department found.`
  String get noDepartmentFound {
    return Intl.message(
      'No department found.',
      name: 'noDepartmentFound',
      desc: '',
      args: [],
    );
  }

  /// `Inactive`
  String get inactive {
    return Intl.message('Inactive', name: 'inactive', desc: '', args: []);
  }

  /// `No description available for this department.`
  String get noDescriptionAvailableForThisDepartment {
    return Intl.message(
      'No description available for this department.',
      name: 'noDescriptionAvailableForThisDepartment',
      desc: '',
      args: [],
    );
  }

  /// `You do not have permission to update Department.`
  String get youDoNotHavePermissionToUpdateDepartment {
    return Intl.message(
      'You do not have permission to update Department.',
      name: 'youDoNotHavePermissionToUpdateDepartment',
      desc: '',
      args: [],
    );
  }

  /// `You do not have permission to delete Department.`
  String get youDoNotHavePermissionToDeleteDepartment {
    return Intl.message(
      'You do not have permission to delete Department.',
      name: 'youDoNotHavePermissionToDeleteDepartment',
      desc: '',
      args: [],
    );
  }

  /// `Failed to delete the Department`
  String get failedToDeleteTheDeterment {
    return Intl.message(
      'Failed to delete the Department',
      name: 'failedToDeleteTheDeterment',
      desc: '',
      args: [],
    );
  }

  /// `Failed to load departments`
  String get failedToLoadDepartment {
    return Intl.message(
      'Failed to load departments',
      name: 'failedToLoadDepartment',
      desc: '',
      args: [],
    );
  }

  /// `Add Department`
  String get addDepartment {
    return Intl.message(
      'Add Department',
      name: 'addDepartment',
      desc: '',
      args: [],
    );
  }

  /// `Saving`
  String get saving {
    return Intl.message('Saving', name: 'saving', desc: '', args: []);
  }

  /// `Edit Designation`
  String get editDesignation {
    return Intl.message(
      'Edit Designation',
      name: 'editDesignation',
      desc: '',
      args: [],
    );
  }

  /// `Add New Designation`
  String get addDesignation {
    return Intl.message(
      'Add New Designation',
      name: 'addDesignation',
      desc: '',
      args: [],
    );
  }

  /// `Designation Name`
  String get designationName {
    return Intl.message(
      'Designation Name',
      name: 'designationName',
      desc: '',
      args: [],
    );
  }

  /// `Enter Designation name`
  String get enterDesignationName {
    return Intl.message(
      'Enter Designation name',
      name: 'enterDesignationName',
      desc: '',
      args: [],
    );
  }

  /// `Please enter designation name`
  String get pleaseEnterDesignationName {
    return Intl.message(
      'Please enter designation name',
      name: 'pleaseEnterDesignationName',
      desc: '',
      args: [],
    );
  }

  /// `Please select a status`
  String get pleaseSelectAStatus {
    return Intl.message(
      'Please select a status',
      name: 'pleaseSelectAStatus',
      desc: '',
      args: [],
    );
  }

  /// `Enter Description`
  String get enterDescription {
    return Intl.message(
      'Enter Description',
      name: 'enterDescription',
      desc: '',
      args: [],
    );
  }

  /// `Designation`
  String get designation {
    return Intl.message('Designation', name: 'designation', desc: '', args: []);
  }

  /// `No designation found.`
  String get noDesignationFound {
    return Intl.message(
      'No designation found.',
      name: 'noDesignationFound',
      desc: '',
      args: [],
    );
  }

  /// `No description available for this designation.`
  String get noDescriptionAvailableForThisDesignation {
    return Intl.message(
      'No description available for this designation.',
      name: 'noDescriptionAvailableForThisDesignation',
      desc: '',
      args: [],
    );
  }

  /// `You do not have permission to update Designation.`
  String get youDoNotPermissionToUpdateDesignation {
    return Intl.message(
      'You do not have permission to update Designation.',
      name: 'youDoNotPermissionToUpdateDesignation',
      desc: '',
      args: [],
    );
  }

  /// `You do not have permission to delete Designation.`
  String get youDoNotHavePermissionToDeleteDesignation {
    return Intl.message(
      'You do not have permission to delete Designation.',
      name: 'youDoNotHavePermissionToDeleteDesignation',
      desc: '',
      args: [],
    );
  }

  /// `Update Purchase`
  String get updatePurchase {
    return Intl.message(
      'Update Purchase',
      name: 'updatePurchase',
      desc: '',
      args: [],
    );
  }

  /// `Edit Employee`
  String get editEmployee {
    return Intl.message(
      'Edit Employee',
      name: 'editEmployee',
      desc: '',
      args: [],
    );
  }

  /// `Add New Employee`
  String get addNewEmployee {
    return Intl.message(
      'Add New Employee',
      name: 'addNewEmployee',
      desc: '',
      args: [],
    );
  }

  /// `Enter Full Name`
  String get enterFullName {
    return Intl.message(
      'Enter Full Name',
      name: 'enterFullName',
      desc: '',
      args: [],
    );
  }

  /// `Please select designation`
  String get pleaseSelectDesignation {
    return Intl.message(
      'Please select designation',
      name: 'pleaseSelectDesignation',
      desc: '',
      args: [],
    );
  }

  /// `Please select department`
  String get pleaseSelectDepartment {
    return Intl.message(
      'Please select department',
      name: 'pleaseSelectDepartment',
      desc: '',
      args: [],
    );
  }

  /// `Please select status`
  String get pleaseSelectStatus {
    return Intl.message(
      'Please select status',
      name: 'pleaseSelectStatus',
      desc: '',
      args: [],
    );
  }

  /// `pleaseEnterYourPhoneNumber`
  String get pleaseEnterYourPhoneNumber {
    return Intl.message(
      'pleaseEnterYourPhoneNumber',
      name: 'pleaseEnterYourPhoneNumber',
      desc: '',
      args: [],
    );
  }

  /// `Country Name`
  String get countryName {
    return Intl.message(
      'Country Name',
      name: 'countryName',
      desc: '',
      args: [],
    );
  }

  /// `Enter your country`
  String get enterYourCountry {
    return Intl.message(
      'Enter your country',
      name: 'enterYourCountry',
      desc: '',
      args: [],
    );
  }

  /// `Salary`
  String get salary {
    return Intl.message('Salary', name: 'salary', desc: '', args: []);
  }

  /// `Please Enter Your Salary`
  String get pleaseEnterYourSalary {
    return Intl.message(
      'Please Enter Your Salary',
      name: 'pleaseEnterYourSalary',
      desc: '',
      args: [],
    );
  }

  /// `Gender`
  String get gender {
    return Intl.message('Gender', name: 'gender', desc: '', args: []);
  }

  /// `Please select your Gender`
  String get pleaseSelectYourGender {
    return Intl.message(
      'Please select your Gender',
      name: 'pleaseSelectYourGender',
      desc: '',
      args: [],
    );
  }

  /// `Please select your shift`
  String get pleaseSelectYourShift {
    return Intl.message(
      'Please select your shift',
      name: 'pleaseSelectYourShift',
      desc: '',
      args: [],
    );
  }

  /// `Birth Date`
  String get birthDate {
    return Intl.message('Birth Date', name: 'birthDate', desc: '', args: []);
  }

  /// `Join Date`
  String get joinDate {
    return Intl.message('Join Date', name: 'joinDate', desc: '', args: []);
  }

  /// `Status`
  String get staus {
    return Intl.message('Status', name: 'staus', desc: '', args: []);
  }

  /// `Please select valid start and end dates.`
  String get pleaseSelectValidStartAndEndDates {
    return Intl.message(
      'Please select valid start and end dates.',
      name: 'pleaseSelectValidStartAndEndDates',
      desc: '',
      args: [],
    );
  }

  /// `End date cannot be before start date.`
  String get endDateCannotBeBeforeStartDate {
    return Intl.message(
      'End date cannot be before start date.',
      name: 'endDateCannotBeBeforeStartDate',
      desc: '',
      args: [],
    );
  }

  /// `Edit Holiday`
  String get editHoliday {
    return Intl.message(
      'Edit Holiday',
      name: 'editHoliday',
      desc: '',
      args: [],
    );
  }

  /// `Add New Holiday`
  String get addNewHoliday {
    return Intl.message(
      'Add New Holiday',
      name: 'addNewHoliday',
      desc: '',
      args: [],
    );
  }

  /// `Enter holiday name`
  String get enterHolidayName {
    return Intl.message(
      'Enter holiday name',
      name: 'enterHolidayName',
      desc: '',
      args: [],
    );
  }

  /// `Please Enter Holiday Name`
  String get pleaseEnterHolidayName {
    return Intl.message(
      'Please Enter Holiday Name',
      name: 'pleaseEnterHolidayName',
      desc: '',
      args: [],
    );
  }

  /// `Please enter date`
  String get pleaseEnterDate {
    return Intl.message(
      'Please enter date',
      name: 'pleaseEnterDate',
      desc: '',
      args: [],
    );
  }

  /// `Please Select Start Date`
  String get pleaseSelectStartDate {
    return Intl.message(
      'Please Select Start Date',
      name: 'pleaseSelectStartDate',
      desc: '',
      args: [],
    );
  }

  /// `Please Select End Date`
  String get pleaseEnterEndDate {
    return Intl.message(
      'Please Select End Date',
      name: 'pleaseEnterEndDate',
      desc: '',
      args: [],
    );
  }

  /// `End date before start date`
  String get endDateBeforeStartDate {
    return Intl.message(
      'End date before start date',
      name: 'endDateBeforeStartDate',
      desc: '',
      args: [],
    );
  }

  /// `Holiday List`
  String get holidayList {
    return Intl.message(
      'Holiday List',
      name: 'holidayList',
      desc: '',
      args: [],
    );
  }

  /// `No holidays found.`
  String get noHolidayFound {
    return Intl.message(
      'No holidays found.',
      name: 'noHolidayFound',
      desc: '',
      args: [],
    );
  }

  /// `No holidays found matching`
  String get noHolidayFundMatching {
    return Intl.message(
      'No holidays found matching',
      name: 'noHolidayFundMatching',
      desc: '',
      args: [],
    );
  }

  /// `Add Holiday`
  String get addHoliday {
    return Intl.message('Add Holiday', name: 'addHoliday', desc: '', args: []);
  }

  /// `You do not have permission to update Holidays.`
  String get youDoNotHavePermissionToUpgradeHoliday {
    return Intl.message(
      'You do not have permission to update Holidays.',
      name: 'youDoNotHavePermissionToUpgradeHoliday',
      desc: '',
      args: [],
    );
  }

  /// `Holiday`
  String get holiday {
    return Intl.message('Holiday', name: 'holiday', desc: '', args: []);
  }

  /// `Edit Leave`
  String get editLeave {
    return Intl.message('Edit Leave', name: 'editLeave', desc: '', args: []);
  }

  /// `Add New Leave`
  String get addNewLeave {
    return Intl.message(
      'Add New Leave',
      name: 'addNewLeave',
      desc: '',
      args: [],
    );
  }

  /// `Leave Type`
  String get leaveType {
    return Intl.message('Leave Type', name: 'leaveType', desc: '', args: []);
  }

  /// `Please select a leave type`
  String get pleaseSelectALeaveType {
    return Intl.message(
      'Please select a leave type',
      name: 'pleaseSelectALeaveType',
      desc: '',
      args: [],
    );
  }

  /// `Please select start date`
  String get pleaseSelectAStartDate {
    return Intl.message(
      'Please select start date',
      name: 'pleaseSelectAStartDate',
      desc: '',
      args: [],
    );
  }

  /// `Leave Duration`
  String get leaveDuration {
    return Intl.message(
      'Leave Duration',
      name: 'leaveDuration',
      desc: '',
      args: [],
    );
  }

  /// `Auto-calculated days`
  String get autoCalculatedDays {
    return Intl.message(
      'Auto-calculated days',
      name: 'autoCalculatedDays',
      desc: '',
      args: [],
    );
  }

  /// `Leave List`
  String get leaveList {
    return Intl.message('Leave List', name: 'leaveList', desc: '', args: []);
  }

  /// `No leave requests found.`
  String get noLeaveRequestFound {
    return Intl.message(
      'No leave requests found.',
      name: 'noLeaveRequestFound',
      desc: '',
      args: [],
    );
  }

  /// `Add Leave`
  String get addLeave {
    return Intl.message('Add Leave', name: 'addLeave', desc: '', args: []);
  }

  /// `No description provided.`
  String get noDescriptionProvided {
    return Intl.message(
      'No description provided.',
      name: 'noDescriptionProvided',
      desc: '',
      args: [],
    );
  }

  /// `You do not have permission to update Leave Request.`
  String get youDoNotHavePermissionToUpdateLeaveRequest {
    return Intl.message(
      'You do not have permission to update Leave Request.',
      name: 'youDoNotHavePermissionToUpdateLeaveRequest',
      desc: '',
      args: [],
    );
  }

  /// `You do not have permission to delete Leave Request.`
  String get youDoNotHavePermissionToDeleteLeaveRequest {
    return Intl.message(
      'You do not have permission to delete Leave Request.',
      name: 'youDoNotHavePermissionToDeleteLeaveRequest',
      desc: '',
      args: [],
    );
  }

  /// `Leave Request`
  String get leaveRequest {
    return Intl.message(
      'Leave Request',
      name: 'leaveRequest',
      desc: '',
      args: [],
    );
  }

  /// `Edit Payroll`
  String get editPayroll {
    return Intl.message(
      'Edit Payroll',
      name: 'editPayroll',
      desc: '',
      args: [],
    );
  }

  /// `Add New Payroll`
  String get addNewPayroll {
    return Intl.message(
      'Add New Payroll',
      name: 'addNewPayroll',
      desc: '',
      args: [],
    );
  }

  /// `Payment Year`
  String get paymentYear {
    return Intl.message(
      'Payment Year',
      name: 'paymentYear',
      desc: '',
      args: [],
    );
  }

  /// `Please select payment year`
  String get pleaseSelectPaymentYear {
    return Intl.message(
      'Please select payment year',
      name: 'pleaseSelectPaymentYear',
      desc: '',
      args: [],
    );
  }

  /// `Please select a month`
  String get pleaseSelectAnMonth {
    return Intl.message(
      'Please select a month',
      name: 'pleaseSelectAnMonth',
      desc: '',
      args: [],
    );
  }

  /// `Please enter date`
  String get pleaseEnterADate {
    return Intl.message(
      'Please enter date',
      name: 'pleaseEnterADate',
      desc: '',
      args: [],
    );
  }

  /// `Total Salary Amount`
  String get totalSalaryAmount {
    return Intl.message(
      'Total Salary Amount',
      name: 'totalSalaryAmount',
      desc: '',
      args: [],
    );
  }

  /// `Payroll List`
  String get payrollList {
    return Intl.message(
      'Payroll List',
      name: 'payrollList',
      desc: '',
      args: [],
    );
  }

  /// `No payroll records found.`
  String get noPayrollFound {
    return Intl.message(
      'No payroll records found.',
      name: 'noPayrollFound',
      desc: '',
      args: [],
    );
  }

  /// `Payment Details`
  String get paymentDetails {
    return Intl.message(
      'Payment Details',
      name: 'paymentDetails',
      desc: '',
      args: [],
    );
  }

  /// `You do not have permission to update PayRoll.`
  String get youDoNotHaveUpdatePayroll {
    return Intl.message(
      'You do not have permission to update PayRoll.',
      name: 'youDoNotHaveUpdatePayroll',
      desc: '',
      args: [],
    );
  }

  /// `You do not have permission to delete RayRoll.`
  String get youDoNotHavePermissionToDeletePayroll {
    return Intl.message(
      'You do not have permission to delete RayRoll.',
      name: 'youDoNotHavePermissionToDeletePayroll',
      desc: '',
      args: [],
    );
  }

  /// `Payroll Record`
  String get payrollRecord {
    return Intl.message(
      'Payroll Record',
      name: 'payrollRecord',
      desc: '',
      args: [],
    );
  }

  /// `Search attendance`
  String get searchAttendance {
    return Intl.message(
      'Search attendance',
      name: 'searchAttendance',
      desc: '',
      args: [],
    );
  }

  /// `Attendance Reports`
  String get attendanceReport {
    return Intl.message(
      'Attendance Reports',
      name: 'attendanceReport',
      desc: '',
      args: [],
    );
  }

  /// `No attendance records found for selected filters.`
  String get noAttendanceRecordFound {
    return Intl.message(
      'No attendance records found for selected filters.',
      name: 'noAttendanceRecordFound',
      desc: '',
      args: [],
    );
  }

  /// `Search leaves`
  String get searchLeave {
    return Intl.message(
      'Search leaves',
      name: 'searchLeave',
      desc: '',
      args: [],
    );
  }

  /// `Leave Reports`
  String get leaveReports {
    return Intl.message(
      'Leave Reports',
      name: 'leaveReports',
      desc: '',
      args: [],
    );
  }

  /// `No leave records found for selected filters.`
  String get noLeaveRecordFound {
    return Intl.message(
      'No leave records found for selected filters.',
      name: 'noLeaveRecordFound',
      desc: '',
      args: [],
    );
  }

  /// `Duration (Days)`
  String get durationDays {
    return Intl.message(
      'Duration (Days)',
      name: 'durationDays',
      desc: '',
      args: [],
    );
  }

  /// `Payroll Reports`
  String get payrollReports {
    return Intl.message(
      'Payroll Reports',
      name: 'payrollReports',
      desc: '',
      args: [],
    );
  }

  /// `No matching payroll records found.`
  String get noMatchingPayrollFound {
    return Intl.message(
      'No matching payroll records found.',
      name: 'noMatchingPayrollFound',
      desc: '',
      args: [],
    );
  }

  /// `Edit Shift`
  String get editShift {
    return Intl.message('Edit Shift', name: 'editShift', desc: '', args: []);
  }

  /// `Add New Shift`
  String get addNewShift {
    return Intl.message(
      'Add New Shift',
      name: 'addNewShift',
      desc: '',
      args: [],
    );
  }

  /// `Shift Name`
  String get shiftName {
    return Intl.message('Shift Name', name: 'shiftName', desc: '', args: []);
  }

  /// `Please select a shift`
  String get pleaseSelectAShift {
    return Intl.message(
      'Please select a shift',
      name: 'pleaseSelectAShift',
      desc: '',
      args: [],
    );
  }

  /// `Break Status`
  String get breakStatus {
    return Intl.message(
      'Break Status',
      name: 'breakStatus',
      desc: '',
      args: [],
    );
  }

  /// `Please select break status`
  String get pleaseSelectBreakStatus {
    return Intl.message(
      'Please select break status',
      name: 'pleaseSelectBreakStatus',
      desc: '',
      args: [],
    );
  }

  /// `Start time is required`
  String get startTimeIsRequired {
    return Intl.message(
      'Start time is required',
      name: 'startTimeIsRequired',
      desc: '',
      args: [],
    );
  }

  /// `Start Time`
  String get startTime {
    return Intl.message('Start Time', name: 'startTime', desc: '', args: []);
  }

  /// `Enter Start Time`
  String get enterStartTime {
    return Intl.message(
      'Enter Start Time',
      name: 'enterStartTime',
      desc: '',
      args: [],
    );
  }

  /// `End time is required`
  String get endTimeIsRequired {
    return Intl.message(
      'End time is required',
      name: 'endTimeIsRequired',
      desc: '',
      args: [],
    );
  }

  /// `End Time`
  String get endTime {
    return Intl.message('End Time', name: 'endTime', desc: '', args: []);
  }

  /// `Enter End Time`
  String get enterEndTime {
    return Intl.message(
      'Enter End Time',
      name: 'enterEndTime',
      desc: '',
      args: [],
    );
  }

  /// `Start Break Time`
  String get startBreakTime {
    return Intl.message(
      'Start Break Time',
      name: 'startBreakTime',
      desc: '',
      args: [],
    );
  }

  /// `Enter Break Time`
  String get enterBreakTime {
    return Intl.message(
      'Enter Break Time',
      name: 'enterBreakTime',
      desc: '',
      args: [],
    );
  }

  /// `End Break Time`
  String get endBreakTime {
    return Intl.message(
      'End Break Time',
      name: 'endBreakTime',
      desc: '',
      args: [],
    );
  }

  /// `No shifts found.`
  String get noShiftFound {
    return Intl.message(
      'No shifts found.',
      name: 'noShiftFound',
      desc: '',
      args: [],
    );
  }

  /// `Add Shift`
  String get addShift {
    return Intl.message('Add Shift', name: 'addShift', desc: '', args: []);
  }

  /// `Break Time`
  String get breakTime {
    return Intl.message('Break Time', name: 'breakTime', desc: '', args: []);
  }

  /// `Break Duration`
  String get breakDuration {
    return Intl.message(
      'Break Duration',
      name: 'breakDuration',
      desc: '',
      args: [],
    );
  }

  /// `You do not have permission to update Shift.`
  String get youDoNotToHavePermissionToUpdateShift {
    return Intl.message(
      'You do not have permission to update Shift.',
      name: 'youDoNotToHavePermissionToUpdateShift',
      desc: '',
      args: [],
    );
  }

  /// `You do not have permission to delete Shift.`
  String get youDoNotToHavePermissionToDeleteShift {
    return Intl.message(
      'You do not have permission to delete Shift.',
      name: 'youDoNotToHavePermissionToDeleteShift',
      desc: '',
      args: [],
    );
  }

  /// `Do you really want to delete this`
  String get doYouReallyWantToDeleteThis {
    return Intl.message(
      'Do you really want to delete this',
      name: 'doYouReallyWantToDeleteThis',
      desc: '',
      args: [],
    );
  }

  /// `View Details`
  String get viewDetails {
    return Intl.message(
      'View Details',
      name: 'viewDetails',
      desc: '',
      args: [],
    );
  }

  /// `Leave`
  String get leave {
    return Intl.message('Leave', name: 'leave', desc: '', args: []);
  }

  /// `Payroll`
  String get payroll {
    return Intl.message('Payroll', name: 'payroll', desc: '', args: []);
  }

  /// `Edit Bank Adjustment`
  String get editBankAdjustment {
    return Intl.message(
      'Edit Bank Adjustment',
      name: 'editBankAdjustment',
      desc: '',
      args: [],
    );
  }

  /// `Adjust Bank Balance`
  String get adjustBankBalance {
    return Intl.message(
      'Adjust Bank Balance',
      name: 'adjustBankBalance',
      desc: '',
      args: [],
    );
  }

  /// `Please add at least one bank account to adjust balances.`
  String get pleaseAddAtLeastOneBank {
    return Intl.message(
      'Please add at least one bank account to adjust balances.',
      name: 'pleaseAddAtLeastOneBank',
      desc: '',
      args: [],
    );
  }

  /// `Account Number`
  String get accountNumber {
    return Intl.message(
      'Account Number',
      name: 'accountNumber',
      desc: '',
      args: [],
    );
  }

  /// `Select account`
  String get selectAccount {
    return Intl.message(
      'Select account',
      name: 'selectAccount',
      desc: '',
      args: [],
    );
  }

  /// `Select type`
  String get selectType {
    return Intl.message('Select type', name: 'selectType', desc: '', args: []);
  }

  /// `Amount is required`
  String get amountsIsRequired {
    return Intl.message(
      'Amount is required',
      name: 'amountsIsRequired',
      desc: '',
      args: [],
    );
  }

  /// `Invalid amount`
  String get invalidAmount {
    return Intl.message(
      'Invalid amount',
      name: 'invalidAmount',
      desc: '',
      args: [],
    );
  }

  /// `Adjustment Date`
  String get adjustmentDate {
    return Intl.message(
      'Adjustment Date',
      name: 'adjustmentDate',
      desc: '',
      args: [],
    );
  }

  /// `Date is required`
  String get dateIsRequired {
    return Intl.message(
      'Date is required',
      name: 'dateIsRequired',
      desc: '',
      args: [],
    );
  }

  /// `Edit Bank Accounts`
  String get editBankAccounts {
    return Intl.message(
      'Edit Bank Accounts',
      name: 'editBankAccounts',
      desc: '',
      args: [],
    );
  }

  /// `Add Bank Accounts`
  String get addNewBankAccounts {
    return Intl.message(
      'Add Bank Accounts',
      name: 'addNewBankAccounts',
      desc: '',
      args: [],
    );
  }

  /// `Account Display Name`
  String get accountDisplayName {
    return Intl.message(
      'Account Display Name',
      name: 'accountDisplayName',
      desc: '',
      args: [],
    );
  }

  /// `Enter account display name`
  String get enterAccountDisplayName {
    return Intl.message(
      'Enter account display name',
      name: 'enterAccountDisplayName',
      desc: '',
      args: [],
    );
  }

  /// `Display name is required`
  String get displayNameIsRequired {
    return Intl.message(
      'Display name is required',
      name: 'displayNameIsRequired',
      desc: '',
      args: [],
    );
  }

  /// `Opening balance is required`
  String get openingBalanceIsRequired {
    return Intl.message(
      'Opening balance is required',
      name: 'openingBalanceIsRequired',
      desc: '',
      args: [],
    );
  }

  /// `As of Date`
  String get asOfDate {
    return Intl.message('As of Date', name: 'asOfDate', desc: '', args: []);
  }

  /// `Hide fields`
  String get hideFiled {
    return Intl.message('Hide fields', name: 'hideFiled', desc: '', args: []);
  }

  /// `Add more fields`
  String get addMoreFiled {
    return Intl.message(
      'Add more fields',
      name: 'addMoreFiled',
      desc: '',
      args: [],
    );
  }

  /// `Enter account number`
  String get enterAccountName {
    return Intl.message(
      'Enter account number',
      name: 'enterAccountName',
      desc: '',
      args: [],
    );
  }

  /// `IFSC Code`
  String get ifscCode {
    return Intl.message('IFSC Code', name: 'ifscCode', desc: '', args: []);
  }

  /// `UPI ID for QR Code`
  String get upiIdForQrCode {
    return Intl.message(
      'UPI ID for QR Code',
      name: 'upiIdForQrCode',
      desc: '',
      args: [],
    );
  }

  /// `Bank Name`
  String get bankName {
    return Intl.message('Bank Name', name: 'bankName', desc: '', args: []);
  }

  /// `Enter Bank Name`
  String get enterBankName {
    return Intl.message(
      'Enter Bank Name',
      name: 'enterBankName',
      desc: '',
      args: [],
    );
  }

  /// `Account Holder Name`
  String get accountHolderName {
    return Intl.message(
      'Account Holder Name',
      name: 'accountHolderName',
      desc: '',
      args: [],
    );
  }

  /// `Enter account holder name`
  String get enterAccountHolderName {
    return Intl.message(
      'Enter account holder name',
      name: 'enterAccountHolderName',
      desc: '',
      args: [],
    );
  }

  /// `Print Bank details on invoices`
  String get printBankDetailsAndInvoice {
    return Intl.message(
      'Print Bank details on invoices',
      name: 'printBankDetailsAndInvoice',
      desc: '',
      args: [],
    );
  }

  /// `Viewing transactions for`
  String get viewingTransactionFor {
    return Intl.message(
      'Viewing transactions for',
      name: 'viewingTransactionFor',
      desc: '',
      args: [],
    );
  }

  /// `Bank Accounts`
  String get bankAccounts {
    return Intl.message(
      'Bank Accounts',
      name: 'bankAccounts',
      desc: '',
      args: [],
    );
  }

  /// `No bank accounts found.`
  String get noBankAccountFound {
    return Intl.message(
      'No bank accounts found.',
      name: 'noBankAccountFound',
      desc: '',
      args: [],
    );
  }

  /// `No accounts found matching`
  String get noAccountsFoundMissing {
    return Intl.message(
      'No accounts found matching',
      name: 'noAccountsFoundMissing',
      desc: '',
      args: [],
    );
  }

  /// `Deposit`
  String get deposit {
    return Intl.message('Deposit', name: 'deposit', desc: '', args: []);
  }

  /// `Add Bank`
  String get addBank {
    return Intl.message('Add Bank', name: 'addBank', desc: '', args: []);
  }

  /// `Bank to Bank Transfer`
  String get bankToBankTransfer {
    return Intl.message(
      'Bank to Bank Transfer',
      name: 'bankToBankTransfer',
      desc: '',
      args: [],
    );
  }

  /// `Bank to Cash Transfer`
  String get bankToCashTransfer {
    return Intl.message(
      'Bank to Cash Transfer',
      name: 'bankToCashTransfer',
      desc: '',
      args: [],
    );
  }

  /// `Account Name`
  String get accountName {
    return Intl.message(
      'Account Name',
      name: 'accountName',
      desc: '',
      args: [],
    );
  }

  /// `Holder Name`
  String get holderName {
    return Intl.message('Holder Name', name: 'holderName', desc: '', args: []);
  }

  /// `Opening Date`
  String get openingDate {
    return Intl.message(
      'Opening Date',
      name: 'openingDate',
      desc: '',
      args: [],
    );
  }

  /// `Current Balance`
  String get currentBalance {
    return Intl.message(
      'Current Balance',
      name: 'currentBalance',
      desc: '',
      args: [],
    );
  }

  /// `Permission denied to delete bank.`
  String get permissionDeniedToDeleteBank {
    return Intl.message(
      'Permission denied to delete bank.',
      name: 'permissionDeniedToDeleteBank',
      desc: '',
      args: [],
    );
  }

  /// `Cannot edit this transaction type.`
  String get canNotEditThisTransactionType {
    return Intl.message(
      'Cannot edit this transaction type.',
      name: 'canNotEditThisTransactionType',
      desc: '',
      args: [],
    );
  }

  /// `Bank`
  String get bank {
    return Intl.message('Bank', name: 'bank', desc: '', args: []);
  }

  /// `No transactions found for this filter.`
  String get noTransactionFoundForThisFilter {
    return Intl.message(
      'No transactions found for this filter.',
      name: 'noTransactionFoundForThisFilter',
      desc: '',
      args: [],
    );
  }

  /// `Please select both accounts.`
  String get pleaseSelectBothAccounts {
    return Intl.message(
      'Please select both accounts.',
      name: 'pleaseSelectBothAccounts',
      desc: '',
      args: [],
    );
  }

  /// `Cannot transfer to the same account.`
  String get cannotTransferToSameAccounts {
    return Intl.message(
      'Cannot transfer to the same account.',
      name: 'cannotTransferToSameAccounts',
      desc: '',
      args: [],
    );
  }

  /// `Edit Bank Transfer`
  String get editBankTransfer {
    return Intl.message(
      'Edit Bank Transfer',
      name: 'editBankTransfer',
      desc: '',
      args: [],
    );
  }

  /// `Need at least two bank accounts to perform a transfer.`
  String get needAtLeastTwoBankAccount {
    return Intl.message(
      'Need at least two bank accounts to perform a transfer.',
      name: 'needAtLeastTwoBankAccount',
      desc: '',
      args: [],
    );
  }

  /// `From`
  String get from {
    return Intl.message('From', name: 'from', desc: '', args: []);
  }

  /// `To`
  String get to {
    return Intl.message('To', name: 'to', desc: '', args: []);
  }

  /// `Edit Bank to Cash`
  String get editBankToCash {
    return Intl.message(
      'Edit Bank to Cash',
      name: 'editBankToCash',
      desc: '',
      args: [],
    );
  }

  /// `No bank accounts found to transfer from.`
  String get noBankAccountsFoundToTransferFrom {
    return Intl.message(
      'No bank accounts found to transfer from.',
      name: 'noBankAccountsFoundToTransferFrom',
      desc: '',
      args: [],
    );
  }

  /// `Select one account`
  String get selectOneAccount {
    return Intl.message(
      'Select one account',
      name: 'selectOneAccount',
      desc: '',
      args: [],
    );
  }

  /// `Edit Cash Adjustment`
  String get editCashAdjustment {
    return Intl.message(
      'Edit Cash Adjustment',
      name: 'editCashAdjustment',
      desc: '',
      args: [],
    );
  }

  /// `Adjust Cash Balance`
  String get adjustCashBalance {
    return Intl.message(
      'Adjust Cash Balance',
      name: 'adjustCashBalance',
      desc: '',
      args: [],
    );
  }

  /// `Custom Date`
  String get customDate {
    return Intl.message('Custom Date', name: 'customDate', desc: '', args: []);
  }

  /// `Cash in Hand`
  String get cashInHand {
    return Intl.message('Cash in Hand', name: 'cashInHand', desc: '', args: []);
  }

  /// `Current Cash Balance`
  String get currentCashBalance {
    return Intl.message(
      'Current Cash Balance',
      name: 'currentCashBalance',
      desc: '',
      args: [],
    );
  }

  /// `Transfer`
  String get transfer {
    return Intl.message('Transfer', name: 'transfer', desc: '', args: []);
  }

  /// `Adjust Cash`
  String get adjustCash {
    return Intl.message('Adjust Cash', name: 'adjustCash', desc: '', args: []);
  }

  /// `Please select a destination bank account.`
  String get pleaseSelectADestinationBankAccounts {
    return Intl.message(
      'Please select a destination bank account.',
      name: 'pleaseSelectADestinationBankAccounts',
      desc: '',
      args: [],
    );
  }

  /// `Edit Cash to Bank`
  String get editCashToBank {
    return Intl.message(
      'Edit Cash to Bank',
      name: 'editCashToBank',
      desc: '',
      args: [],
    );
  }

  /// `Cash To Bank Transfer`
  String get cashToBankTransfer {
    return Intl.message(
      'Cash To Bank Transfer',
      name: 'cashToBankTransfer',
      desc: '',
      args: [],
    );
  }

  /// `No destination bank accounts found.`
  String get noDestinationBankAccountFond {
    return Intl.message(
      'No destination bank accounts found.',
      name: 'noDestinationBankAccountFond',
      desc: '',
      args: [],
    );
  }

  /// `Transfer Cheque`
  String get transferCheque {
    return Intl.message(
      'Transfer Cheque',
      name: 'transferCheque',
      desc: '',
      args: [],
    );
  }

  /// `Received From`
  String get receivedFrom {
    return Intl.message(
      'Received From',
      name: 'receivedFrom',
      desc: '',
      args: [],
    );
  }

  /// `Cheque Amount`
  String get chequeAmount {
    return Intl.message(
      'Cheque Amount',
      name: 'chequeAmount',
      desc: '',
      args: [],
    );
  }

  /// `Cheque Number`
  String get chequeNumber {
    return Intl.message(
      'Cheque Number',
      name: 'chequeNumber',
      desc: '',
      args: [],
    );
  }

  /// `Cheque Date`
  String get chequeDate {
    return Intl.message('Cheque Date', name: 'chequeDate', desc: '', args: []);
  }

  /// `Reference No`
  String get referenceNumber {
    return Intl.message(
      'Reference No',
      name: 'referenceNumber',
      desc: '',
      args: [],
    );
  }

  /// `Select Bank or Cash`
  String get selectBankToCash {
    return Intl.message(
      'Select Bank or Cash',
      name: 'selectBankToCash',
      desc: '',
      args: [],
    );
  }

  /// `Deposit To`
  String get depositTo {
    return Intl.message('Deposit To', name: 'depositTo', desc: '', args: []);
  }

  /// `Select deposit destination`
  String get selectDepositDestination {
    return Intl.message(
      'Select deposit destination',
      name: 'selectDepositDestination',
      desc: '',
      args: [],
    );
  }

  /// `Transfer Date`
  String get transferDate {
    return Intl.message(
      'Transfer Date',
      name: 'transferDate',
      desc: '',
      args: [],
    );
  }

  /// `Do you really want to re-open this cheque?`
  String get doYouWantToRellyReOpenThisCheque {
    return Intl.message(
      'Do you really want to re-open this cheque?',
      name: 'doYouWantToRellyReOpenThisCheque',
      desc: '',
      args: [],
    );
  }

  /// `Okay`
  String get okay {
    return Intl.message('Okay', name: 'okay', desc: '', args: []);
  }

  /// `Re-Open`
  String get reOpen {
    return Intl.message('Re-Open', name: 'reOpen', desc: '', args: []);
  }

  /// `Open`
  String get open {
    return Intl.message('Open', name: 'open', desc: '', args: []);
  }

  /// `Cheques List`
  String get chequeList {
    return Intl.message('Cheques List', name: 'chequeList', desc: '', args: []);
  }

  /// `Closed`
  String get closed {
    return Intl.message('Closed', name: 'closed', desc: '', args: []);
  }

  /// `No cheques found`
  String get noChequeFound {
    return Intl.message(
      'No cheques found',
      name: 'noChequeFound',
      desc: '',
      args: [],
    );
  }

  /// `Search transactions...`
  String get searchTransaction {
    return Intl.message(
      'Search transactions...',
      name: 'searchTransaction',
      desc: '',
      args: [],
    );
  }

  /// `Filter by Date`
  String get filterByDate {
    return Intl.message(
      'Filter by Date',
      name: 'filterByDate',
      desc: '',
      args: [],
    );
  }

  /// `Add Image`
  String get addImage {
    return Intl.message('Add Image', name: 'addImage', desc: '', args: []);
  }

  /// `Cash & Bank Management`
  String get cashAndBankManagement {
    return Intl.message(
      'Cash & Bank Management',
      name: 'cashAndBankManagement',
      desc: '',
      args: [],
    );
  }

  /// `Cheques`
  String get cheque {
    return Intl.message('Cheques', name: 'cheque', desc: '', args: []);
  }

  /// `Branch List`
  String get branchList {
    return Intl.message('Branch List', name: 'branchList', desc: '', args: []);
  }

  /// `Role & Permission`
  String get roleAndPermission {
    return Intl.message(
      'Role & Permission',
      name: 'roleAndPermission',
      desc: '',
      args: [],
    );
  }

  /// `Switch Branch?`
  String get switchBank {
    return Intl.message(
      'Switch Branch?',
      name: 'switchBank',
      desc: '',
      args: [],
    );
  }

  /// `Exit Branch`
  String get exitBank {
    return Intl.message('Exit Branch', name: 'exitBank', desc: '', args: []);
  }

  /// `Are you sure you want to switch to a different branch?`
  String get areYouSureWantToSwitchToDifferentBranch {
    return Intl.message(
      'Are you sure you want to switch to a different branch?',
      name: 'areYouSureWantToSwitchToDifferentBranch',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to Exit from this branch?`
  String get areYourSureYouWantToExitFromThisBranch {
    return Intl.message(
      'Are you sure you want to Exit from this branch?',
      name: 'areYourSureYouWantToExitFromThisBranch',
      desc: '',
      args: [],
    );
  }

  /// `Switch`
  String get switchs {
    return Intl.message('Switch', name: 'switchs', desc: '', args: []);
  }

  /// `Exit`
  String get exit {
    return Intl.message('Exit', name: 'exit', desc: '', args: []);
  }

  /// `Create Brunch`
  String get createBranch {
    return Intl.message(
      'Create Brunch',
      name: 'createBranch',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete this Brunch?`
  String get areYouSureWantToDeleteThisBranch {
    return Intl.message(
      'Are you sure you want to delete this Brunch?',
      name: 'areYouSureWantToDeleteThisBranch',
      desc: '',
      args: [],
    );
  }

  /// `Current`
  String get currents {
    return Intl.message('Current', name: 'currents', desc: '', args: []);
  }

  /// `No Branch Found`
  String get noBrunchFound {
    return Intl.message(
      'No Branch Found',
      name: 'noBrunchFound',
      desc: '',
      args: [],
    );
  }

  /// `Update Branch`
  String get updateBranch {
    return Intl.message(
      'Update Branch',
      name: 'updateBranch',
      desc: '',
      args: [],
    );
  }

  /// `Please enter branch name`
  String get pleaseEnterBranchName {
    return Intl.message(
      'Please enter branch name',
      name: 'pleaseEnterBranchName',
      desc: '',
      args: [],
    );
  }

  /// `Enter Balance`
  String get enterBalance {
    return Intl.message(
      'Enter Balance',
      name: 'enterBalance',
      desc: '',
      args: [],
    );
  }

  /// `You do not have permission to update branch.`
  String get youDoNotHavePermissionToUpdateBranch {
    return Intl.message(
      'You do not have permission to update branch.',
      name: 'youDoNotHavePermissionToUpdateBranch',
      desc: '',
      args: [],
    );
  }

  /// `All Transaction`
  String get allTransaction {
    return Intl.message(
      'All Transaction',
      name: 'allTransaction',
      desc: '',
      args: [],
    );
  }

  /// `Due Pay`
  String get duePay {
    return Intl.message('Due Pay', name: 'duePay', desc: '', args: []);
  }

  /// `All Parties`
  String get allParties {
    return Intl.message('All Parties', name: 'allParties', desc: '', args: []);
  }

  /// `Retry`
  String get retry {
    return Intl.message('Retry', name: 'retry', desc: '', args: []);
  }

  /// `Income Categories Report`
  String get incomeCategoriesReport {
    return Intl.message(
      'Income Categories Report',
      name: 'incomeCategoriesReport',
      desc: '',
      args: [],
    );
  }

  /// `Day Book`
  String get dayBook {
    return Intl.message('Day Book', name: 'dayBook', desc: '', args: []);
  }

  /// `Bill wise profit`
  String get billWiseProfit {
    return Intl.message(
      'Bill wise profit',
      name: 'billWiseProfit',
      desc: '',
      args: [],
    );
  }

  /// `Cashflow`
  String get cashFlow {
    return Intl.message('Cashflow', name: 'cashFlow', desc: '', args: []);
  }

  /// `Balance sheet`
  String get balanceSheet {
    return Intl.message(
      'Balance sheet',
      name: 'balanceSheet',
      desc: '',
      args: [],
    );
  }

  /// `Tax Report`
  String get taxReport {
    return Intl.message('Tax Report', name: 'taxReport', desc: '', args: []);
  }

  /// `Product Sale History`
  String get productSaleHistory {
    return Intl.message(
      'Product Sale History',
      name: 'productSaleHistory',
      desc: '',
      args: [],
    );
  }

  /// `Product Purchase History`
  String get productPurchaseHistory {
    return Intl.message(
      'Product Purchase History',
      name: 'productPurchaseHistory',
      desc: '',
      args: [],
    );
  }

  /// `Party Reports`
  String get partyReports {
    return Intl.message(
      'Party Reports',
      name: 'partyReports',
      desc: '',
      args: [],
    );
  }

  /// `Customer Ledger`
  String get customerLedger {
    return Intl.message(
      'Customer Ledger',
      name: 'customerLedger',
      desc: '',
      args: [],
    );
  }

  /// `Supplier Ledger`
  String get supplierLedger {
    return Intl.message(
      'Supplier Ledger',
      name: 'supplierLedger',
      desc: '',
      args: [],
    );
  }

  /// `Party wise profit`
  String get partyWiseProfit {
    return Intl.message(
      'Party wise profit',
      name: 'partyWiseProfit',
      desc: '',
      args: [],
    );
  }

  /// `Product wise profit`
  String get productWiseProfit {
    return Intl.message(
      'Product wise profit',
      name: 'productWiseProfit',
      desc: '',
      args: [],
    );
  }

  /// `Top 5 Customer`
  String get top5Customer {
    return Intl.message(
      'Top 5 Customer',
      name: 'top5Customer',
      desc: '',
      args: [],
    );
  }

  /// `Top 5 Supplier`
  String get top5Supplier {
    return Intl.message(
      'Top 5 Supplier',
      name: 'top5Supplier',
      desc: '',
      args: [],
    );
  }

  /// `Product Reports`
  String get productReports {
    return Intl.message(
      'Product Reports',
      name: 'productReports',
      desc: '',
      args: [],
    );
  }

  /// `Combo report`
  String get comboReport {
    return Intl.message(
      'Combo report',
      name: 'comboReport',
      desc: '',
      args: [],
    );
  }

  /// `Expired item report`
  String get expiredItemReport {
    return Intl.message(
      'Expired item report',
      name: 'expiredItemReport',
      desc: '',
      args: [],
    );
  }

  /// `Top 5 Product`
  String get top5Product {
    return Intl.message(
      'Top 5 Product',
      name: 'top5Product',
      desc: '',
      args: [],
    );
  }

  /// `Product Wise Profit & Loss`
  String get productWiseProfitAndLoss {
    return Intl.message(
      'Product Wise Profit & Loss',
      name: 'productWiseProfitAndLoss',
      desc: '',
      args: [],
    );
  }

  /// `Product Wise Purchase`
  String get productWisePurchase {
    return Intl.message(
      'Product Wise Purchase',
      name: 'productWisePurchase',
      desc: '',
      args: [],
    );
  }

  /// `No products match your search.`
  String get noProductMatchYourSearch {
    return Intl.message(
      'No products match your search.',
      name: 'noProductMatchYourSearch',
      desc: '',
      args: [],
    );
  }

  /// `Purchase Qty`
  String get purchaseQty {
    return Intl.message(
      'Purchase Qty',
      name: 'purchaseQty',
      desc: '',
      args: [],
    );
  }

  /// `Sale Qty`
  String get saleQty {
    return Intl.message('Sale Qty', name: 'saleQty', desc: '', args: []);
  }

  /// `You do not have permission of loss profit.`
  String get youDoNotHavePermissionProfitAndLoss {
    return Intl.message(
      'You do not have permission of loss profit.',
      name: 'youDoNotHavePermissionProfitAndLoss',
      desc: '',
      args: [],
    );
  }

  /// `Sold`
  String get sold {
    return Intl.message('Sold', name: 'sold', desc: '', args: []);
  }

  /// `Remaining`
  String get remaining {
    return Intl.message('Remaining', name: 'remaining', desc: '', args: []);
  }

  /// `Total Assets`
  String get totalAssets {
    return Intl.message(
      'Total Assets',
      name: 'totalAssets',
      desc: '',
      args: [],
    );
  }

  /// `Assets`
  String get assets {
    return Intl.message('Assets', name: 'assets', desc: '', args: []);
  }

  /// `Item Name`
  String get itemName {
    return Intl.message('Item Name', name: 'itemName', desc: '', args: []);
  }

  /// `Personal Info:`
  String get personalInfo {
    return Intl.message(
      'Personal Info:',
      name: 'personalInfo',
      desc: '',
      args: [],
    );
  }

  /// `Due Balance`
  String get dueBalance {
    return Intl.message('Due Balance', name: 'dueBalance', desc: '', args: []);
  }

  /// `Wallet Balance`
  String get walletBalance {
    return Intl.message(
      'Wallet Balance',
      name: 'walletBalance',
      desc: '',
      args: [],
    );
  }

  /// `Cash In`
  String get cashIn {
    return Intl.message('Cash In', name: 'cashIn', desc: '', args: []);
  }

  /// `Cash Out`
  String get cashOut {
    return Intl.message('Cash Out', name: 'cashOut', desc: '', args: []);
  }

  /// `Running Cash`
  String get runningCash {
    return Intl.message(
      'Running Cash',
      name: 'runningCash',
      desc: '',
      args: [],
    );
  }

  /// `Money In`
  String get moneyIn {
    return Intl.message('Money In', name: 'moneyIn', desc: '', args: []);
  }

  /// `Money Out`
  String get moneyOut {
    return Intl.message('Money Out', name: 'moneyOut', desc: '', args: []);
  }

  /// `No data available for generate pdf`
  String get noDataAvailableForGeneratePdf {
    return Intl.message(
      'No data available for generate pdf',
      name: 'noDataAvailableForGeneratePdf',
      desc: '',
      args: [],
    );
  }

  /// `Balance Due`
  String get balanceDue {
    return Intl.message('Balance Due', name: 'balanceDue', desc: '', args: []);
  }

  /// `Returned Amount`
  String get returnedAmount {
    return Intl.message(
      'Returned Amount',
      name: 'returnedAmount',
      desc: '',
      args: [],
    );
  }

  /// `Sale return`
  String get saleReturn {
    return Intl.message('Sale return', name: 'saleReturn', desc: '', args: []);
  }

  /// `Sales Edit`
  String get saleEdit {
    return Intl.message('Sales Edit', name: 'saleEdit', desc: '', args: []);
  }

  /// `Please Add A Sale Return`
  String get pleaseAddASalesReturn {
    return Intl.message(
      'Please Add A Sale Return',
      name: 'pleaseAddASalesReturn',
      desc: '',
      args: [],
    );
  }

  /// `Subscription Reports`
  String get subscriptionReports {
    return Intl.message(
      'Subscription Reports',
      name: 'subscriptionReports',
      desc: '',
      args: [],
    );
  }

  /// `Started`
  String get started {
    return Intl.message('Started', name: 'started', desc: '', args: []);
  }

  /// `End`
  String get end {
    return Intl.message('End', name: 'end', desc: '', args: []);
  }

  /// `Tax Report List`
  String get taxReportList {
    return Intl.message(
      'Tax Report List',
      name: 'taxReportList',
      desc: '',
      args: [],
    );
  }

  /// `Developed By`
  String get developedBy {
    return Intl.message(
      'Developed By',
      name: 'developedBy',
      desc: '',
      args: [],
    );
  }

  /// `Time`
  String get time {
    return Intl.message('Time', name: 'time', desc: '', args: []);
  }

  /// `Received By`
  String get receivedBy {
    return Intl.message('Received By', name: 'receivedBy', desc: '', args: []);
  }

  /// `Wallet`
  String get wallet {
    return Intl.message('Wallet', name: 'wallet', desc: '', args: []);
  }

  /// `Warranty`
  String get warranty {
    return Intl.message('Warranty', name: 'warranty', desc: '', args: []);
  }

  /// `Guarantee`
  String get guarantee {
    return Intl.message('Guarantee', name: 'guarantee', desc: '', args: []);
  }

  /// `Remark`
  String get remark {
    return Intl.message('Remark', name: 'remark', desc: '', args: []);
  }

  /// `Bank Details`
  String get bankDetails {
    return Intl.message(
      'Bank Details',
      name: 'bankDetails',
      desc: '',
      args: [],
    );
  }

  /// `Cash & Bank`
  String get cashAndBank {
    return Intl.message('Cash & Bank', name: 'cashAndBank', desc: '', args: []);
  }

  /// `Pdf Generate Successfully`
  String get pdfGenerateSuccessfully {
    return Intl.message(
      'Pdf Generate Successfully',
      name: 'pdfGenerateSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Generating PDF`
  String get generatingPdf {
    return Intl.message(
      'Generating PDF',
      name: 'generatingPdf',
      desc: '',
      args: [],
    );
  }

  /// `INVOICE`
  String get INVOICE {
    return Intl.message('INVOICE', name: 'INVOICE', desc: '', args: []);
  }

  /// `Admin`
  String get admin {
    return Intl.message('Admin', name: 'admin', desc: '', args: []);
  }

  /// `Invoice Number`
  String get invoiceNumber {
    return Intl.message(
      'Invoice Number',
      name: 'invoiceNumber',
      desc: '',
      args: [],
    );
  }

  /// `VAT Number`
  String get vatNumber {
    return Intl.message('VAT Number', name: 'vatNumber', desc: '', args: []);
  }

  /// `Customer Signature`
  String get customerSignature {
    return Intl.message(
      'Customer Signature',
      name: 'customerSignature',
      desc: '',
      args: [],
    );
  }

  /// `Authorized Signature`
  String get authorizedSignature {
    return Intl.message(
      'Authorized Signature',
      name: 'authorizedSignature',
      desc: '',
      args: [],
    );
  }

  /// `Powered By`
  String get poweredBy {
    return Intl.message('Powered By', name: 'poweredBy', desc: '', args: []);
  }

  /// `Shipping Charge`
  String get shippingCharge {
    return Intl.message(
      'Shipping Charge',
      name: 'shippingCharge',
      desc: '',
      args: [],
    );
  }

  /// `Total Returned`
  String get totalReturned {
    return Intl.message(
      'Total Returned',
      name: 'totalReturned',
      desc: '',
      args: [],
    );
  }

  /// `Amounts in Words`
  String get amountsInWord {
    return Intl.message(
      'Amounts in Words',
      name: 'amountsInWord',
      desc: '',
      args: [],
    );
  }

  /// `Change Amount`
  String get changeAmount {
    return Intl.message(
      'Change Amount',
      name: 'changeAmount',
      desc: '',
      args: [],
    );
  }

  /// `Sells By`
  String get sellsBy {
    return Intl.message('Sells By', name: 'sellsBy', desc: '', args: []);
  }

  /// `Rounding`
  String get rounding {
    return Intl.message('Rounding', name: 'rounding', desc: '', args: []);
  }

  /// `Paid By`
  String get paidBy {
    return Intl.message('Paid By', name: 'paidBy', desc: '', args: []);
  }

  /// `VAT/GST Tittle`
  String get vatGstTitle {
    return Intl.message(
      'VAT/GST Tittle',
      name: 'vatGstTitle',
      desc: '',
      args: [],
    );
  }

  /// `Enter VAT/GST Title`
  String get enterVatGstTitle {
    return Intl.message(
      'Enter VAT/GST Title',
      name: 'enterVatGstTitle',
      desc: '',
      args: [],
    );
  }

  /// `VAT/GST Number`
  String get vatGstNumber {
    return Intl.message(
      'VAT/GST Number',
      name: 'vatGstNumber',
      desc: '',
      args: [],
    );
  }

  /// `Enter VAT/GST Number`
  String get enterVatGstNumber {
    return Intl.message(
      'Enter VAT/GST Number',
      name: 'enterVatGstNumber',
      desc: '',
      args: [],
    );
  }

  /// `Vat & Tax`
  String get vatAndTax {
    return Intl.message('Vat & Tax', name: 'vatAndTax', desc: '', args: []);
  }

  /// `Custom Print`
  String get customPrint {
    return Intl.message(
      'Custom Print',
      name: 'customPrint',
      desc: '',
      args: [],
    );
  }

  /// `Tax Rates`
  String get taxRates {
    return Intl.message('Tax Rates', name: 'taxRates', desc: '', args: []);
  }

  /// `Tax rates- Manage your Tax Rates`
  String get taxRatesMangeYourTaxRates {
    return Intl.message(
      'Tax rates- Manage your Tax Rates',
      name: 'taxRatesMangeYourTaxRates',
      desc: '',
      args: [],
    );
  }

  /// `Add`
  String get add {
    return Intl.message('Add', name: 'add', desc: '', args: []);
  }

  /// `Status`
  String get status {
    return Intl.message('Status', name: 'status', desc: '', args: []);
  }

  /// `Active`
  String get active {
    return Intl.message('Active', name: 'active', desc: '', args: []);
  }

  /// `Disable`
  String get disable {
    return Intl.message('Disable', name: 'disable', desc: '', args: []);
  }

  /// `Deleted successfully!`
  String get deletedSuccessFully {
    return Intl.message(
      'Deleted successfully!',
      name: 'deletedSuccessFully',
      desc: '',
      args: [],
    );
  }

  /// `Failed to delete the tax`
  String get failedToDeleteTheTax {
    return Intl.message(
      'Failed to delete the tax',
      name: 'failedToDeleteTheTax',
      desc: '',
      args: [],
    );
  }

  /// `Error deleting tax`
  String get errorDeletingTax {
    return Intl.message(
      'Error deleting tax',
      name: 'errorDeletingTax',
      desc: '',
      args: [],
    );
  }

  /// `Tax Group`
  String get taxGroup {
    return Intl.message('Tax Group', name: 'taxGroup', desc: '', args: []);
  }

  /// `Combination of multiple taxes`
  String get combinationOfTheMultipleTaxes {
    return Intl.message(
      'Combination of multiple taxes',
      name: 'combinationOfTheMultipleTaxes',
      desc: '',
      args: [],
    );
  }

  /// `Sub Taxes`
  String get subTaxes {
    return Intl.message('Sub Taxes', name: 'subTaxes', desc: '', args: []);
  }

  /// `Action`
  String get action {
    return Intl.message('Action', name: 'action', desc: '', args: []);
  }

  /// `Add Tax`
  String get addTax {
    return Intl.message('Add Tax', name: 'addTax', desc: '', args: []);
  }

  /// `Edit Tax`
  String get editTax {
    return Intl.message('Edit Tax', name: 'editTax', desc: '', args: []);
  }

  /// `Add New Tax`
  String get addNewTax {
    return Intl.message('Add New Tax', name: 'addNewTax', desc: '', args: []);
  }

  /// `Enter Tax Rate`
  String get enterTaxRates {
    return Intl.message(
      'Enter Tax Rate',
      name: 'enterTaxRates',
      desc: '',
      args: [],
    );
  }

  /// `Add New Tax`
  String get addTaxGroup {
    return Intl.message('Add New Tax', name: 'addTaxGroup', desc: '', args: []);
  }

  /// `Edit Tax Group`
  String get editTaxGroup {
    return Intl.message(
      'Edit Tax Group',
      name: 'editTaxGroup',
      desc: '',
      args: [],
    );
  }

  /// `Tax with single/multiple Tax type`
  String get taxWithSingleMultipleTaxType {
    return Intl.message(
      'Tax with single/multiple Tax type',
      name: 'taxWithSingleMultipleTaxType',
      desc: '',
      args: [],
    );
  }

  /// `No Sub Tax Selected`
  String get noSubTaxSelected {
    return Intl.message(
      'No Sub Tax Selected',
      name: 'noSubTaxSelected',
      desc: '',
      args: [],
    );
  }

  /// `Sub Tax List`
  String get subTaxList {
    return Intl.message('Sub Tax List', name: 'subTaxList', desc: '', args: []);
  }

  /// `Tax percent`
  String get taxPercent {
    return Intl.message('Tax percent', name: 'taxPercent', desc: '', args: []);
  }

  /// `Done`
  String get done {
    return Intl.message('Done', name: 'done', desc: '', args: []);
  }

  /// `Write text here...`
  String get writerTaxHere {
    return Intl.message(
      'Write text here...',
      name: 'writerTaxHere',
      desc: '',
      args: [],
    );
  }

  /// `Expired List`
  String get expiredList {
    return Intl.message(
      'Expired List',
      name: 'expiredList',
      desc: '',
      args: [],
    );
  }

  /// `List is Empty`
  String get listIsEmpty {
    return Intl.message(
      'List is Empty',
      name: 'listIsEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Printing Invoice`
  String get printingInvoice {
    return Intl.message(
      'Printing Invoice',
      name: 'printingInvoice',
      desc: '',
      args: [],
    );
  }

  /// `Sales Settings`
  String get salesSetting {
    return Intl.message(
      'Sales Settings',
      name: 'salesSetting',
      desc: '',
      args: [],
    );
  }

  /// `Invoice Logo`
  String get invoiceLogo {
    return Intl.message(
      'Invoice Logo',
      name: 'invoiceLogo',
      desc: '',
      args: [],
    );
  }

  /// `Printing Option`
  String get printingOption {
    return Intl.message(
      'Printing Option',
      name: 'printingOption',
      desc: '',
      args: [],
    );
  }

  /// `Amount rounding method`
  String get amountRoundingMethod {
    return Intl.message(
      'Amount rounding method',
      name: 'amountRoundingMethod',
      desc: '',
      args: [],
    );
  }

  /// `Sign Up`
  String get signUp {
    return Intl.message('Sign Up', name: 'signUp', desc: '', args: []);
  }

  /// `Barcode Generator`
  String get barcodeGenerator {
    return Intl.message(
      'Barcode Generator',
      name: 'barcodeGenerator',
      desc: '',
      args: [],
    );
  }

  /// `Search Product`
  String get searchProduct {
    return Intl.message(
      'Search Product',
      name: 'searchProduct',
      desc: '',
      args: [],
    );
  }

  /// `Code`
  String get code {
    return Intl.message('Code', name: 'code', desc: '', args: []);
  }

  /// `Price`
  String get price {
    return Intl.message('Price', name: 'price', desc: '', args: []);
  }

  /// `Show code`
  String get showCode {
    return Intl.message('Show code', name: 'showCode', desc: '', args: []);
  }

  /// `Show Price`
  String get showPrice {
    return Intl.message('Show Price', name: 'showPrice', desc: '', args: []);
  }

  /// `Show Name`
  String get showName {
    return Intl.message('Show Name', name: 'showName', desc: '', args: []);
  }

  /// `Actions`
  String get actions {
    return Intl.message('Actions', name: 'actions', desc: '', args: []);
  }

  /// `No Item Selected`
  String get noItemSelected {
    return Intl.message(
      'No Item Selected',
      name: 'noItemSelected',
      desc: '',
      args: [],
    );
  }

  /// `No Product Selected`
  String get noProductSelected {
    return Intl.message(
      'No Product Selected',
      name: 'noProductSelected',
      desc: '',
      args: [],
    );
  }

  /// `Preview PDF`
  String get previewPdf {
    return Intl.message('Preview PDF', name: 'previewPdf', desc: '', args: []);
  }

  /// `Sales Return Report`
  String get salesReturnReport {
    return Intl.message(
      'Sales Return Report',
      name: 'salesReturnReport',
      desc: '',
      args: [],
    );
  }

  /// `Purchase Return Report`
  String get purchaseReturnReport {
    return Intl.message(
      'Purchase Return Report',
      name: 'purchaseReturnReport',
      desc: '',
      args: [],
    );
  }

  /// `Income For`
  String get incomeFor {
    return Intl.message('Income For', name: 'incomeFor', desc: '', args: []);
  }

  /// `Enter product code`
  String get enterProductCode {
    return Intl.message(
      'Enter product code',
      name: 'enterProductCode',
      desc: '',
      args: [],
    );
  }

  /// `Add Income`
  String get addIncome {
    return Intl.message('Add Income', name: 'addIncome', desc: '', args: []);
  }

  /// `Income Date`
  String get incomeDate {
    return Intl.message('Income Date', name: 'incomeDate', desc: '', args: []);
  }

  /// `Income Categories`
  String get incomeCategories {
    return Intl.message(
      'Income Categories',
      name: 'incomeCategories',
      desc: '',
      args: [],
    );
  }

  /// `Add Income Category`
  String get addIncomeCategory {
    return Intl.message(
      'Add Income Category',
      name: 'addIncomeCategory',
      desc: '',
      args: [],
    );
  }

  /// `Enter income category name`
  String get enterIncomeCategoryName {
    return Intl.message(
      'Enter income category name',
      name: 'enterIncomeCategoryName',
      desc: '',
      args: [],
    );
  }

  /// `Total Returned Amount`
  String get totalReturnAmount {
    return Intl.message(
      'Total Returned Amount',
      name: 'totalReturnAmount',
      desc: '',
      args: [],
    );
  }

  /// `Returned`
  String get returned {
    return Intl.message('Returned', name: 'returned', desc: '', args: []);
  }

  /// `Supplier Details`
  String get supplierDetails {
    return Intl.message(
      'Supplier Details',
      name: 'supplierDetails',
      desc: '',
      args: [],
    );
  }

  /// `Weekly`
  String get weekly {
    return Intl.message('Weekly', name: 'weekly', desc: '', args: []);
  }

  /// `Monthly`
  String get monthly {
    return Intl.message('Monthly', name: 'monthly', desc: '', args: []);
  }

  /// `Yearly`
  String get yearly {
    return Intl.message('Yearly', name: 'yearly', desc: '', args: []);
  }

  /// `Today`
  String get today {
    return Intl.message('Today', name: 'today', desc: '', args: []);
  }

  /// `This Week`
  String get thisWeek {
    return Intl.message('This Week', name: 'thisWeek', desc: '', args: []);
  }

  /// `This Month`
  String get thisMonth {
    return Intl.message('This Month', name: 'thisMonth', desc: '', args: []);
  }

  /// `This Year`
  String get thisYear {
    return Intl.message('This Year', name: 'thisYear', desc: '', args: []);
  }

  /// `All Time`
  String get allTime {
    return Intl.message('All Time', name: 'allTime', desc: '', args: []);
  }

  /// `Custom`
  String get custom {
    return Intl.message('Custom', name: 'custom', desc: '', args: []);
  }

  /// `Add User Role`
  String get addUserRole {
    return Intl.message(
      'Add User Role',
      name: 'addUserRole',
      desc: '',
      args: [],
    );
  }

  /// `No User Role Found`
  String get noRoleFound {
    return Intl.message(
      'No User Role Found',
      name: 'noRoleFound',
      desc: '',
      args: [],
    );
  }

  /// `Your Package Will Expire in 5 Day`
  String get yourPackageExpiredInDays {
    return Intl.message(
      'Your Package Will Expire in 5 Day',
      name: 'yourPackageExpiredInDays',
      desc: '',
      args: [],
    );
  }

  /// `Your Package Will Expire Today\n\nPlease Purchase again`
  String get yourPackageExpiredToday {
    return Intl.message(
      'Your Package Will Expire Today\n\nPlease Purchase again',
      name: 'yourPackageExpiredToday',
      desc: '',
      args: [],
    );
  }

  /// `Contact Us`
  String get contactUs {
    return Intl.message('Contact Us', name: 'contactUs', desc: '', args: []);
  }

  /// `Write your message here`
  String get writeYourMessageHere {
    return Intl.message(
      'Write your message here',
      name: 'writeYourMessageHere',
      desc: '',
      args: [],
    );
  }

  /// `Send Message`
  String get sendMessage {
    return Intl.message(
      'Send Message',
      name: 'sendMessage',
      desc: '',
      args: [],
    );
  }

  /// `Send your Email`
  String get sendYourEmail {
    return Intl.message(
      'Send your Email',
      name: 'sendYourEmail',
      desc: '',
      args: [],
    );
  }

  /// `Back To Home`
  String get backToHome {
    return Intl.message('Back To Home', name: 'backToHome', desc: '', args: []);
  }

  /// `Promo Code`
  String get promoCode {
    return Intl.message('Promo Code', name: 'promoCode', desc: '', args: []);
  }

  /// `Submit`
  String get submit {
    return Intl.message('Submit', name: 'submit', desc: '', args: []);
  }

  /// `See all promo code`
  String get seeAllPromoCode {
    return Intl.message(
      'See all promo code',
      name: 'seeAllPromoCode',
      desc: '',
      args: [],
    );
  }

  /// `Categories`
  String get categories {
    return Intl.message('Categories', name: 'categories', desc: '', args: []);
  }

  /// `Enter your phone number`
  String get enterYourPhoneNumber {
    return Intl.message(
      'Enter your phone number',
      name: 'enterYourPhoneNumber',
      desc: '',
      args: [],
    );
  }

  /// `Enter Full Address`
  String get enterFullAddress {
    return Intl.message(
      'Enter Full Address',
      name: 'enterFullAddress',
      desc: '',
      args: [],
    );
  }

  /// `Enter your email address`
  String get enterYourEmailAddress {
    return Intl.message(
      'Enter your email address',
      name: 'enterYourEmailAddress',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a password`
  String get pleaseEnterAPassword {
    return Intl.message(
      'Please enter a password',
      name: 'pleaseEnterAPassword',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a confirm password`
  String get pleaseEnterAConfirmPassword {
    return Intl.message(
      'Please enter a confirm password',
      name: 'pleaseEnterAConfirmPassword',
      desc: '',
      args: [],
    );
  }

  /// `Enter your name`
  String get enterYourName {
    return Intl.message(
      'Enter your name',
      name: 'enterYourName',
      desc: '',
      args: [],
    );
  }

  /// `Add New Address`
  String get addNewAddress {
    return Intl.message(
      'Add New Address',
      name: 'addNewAddress',
      desc: '',
      args: [],
    );
  }

  /// `First Name`
  String get firstName {
    return Intl.message('First Name', name: 'firstName', desc: '', args: []);
  }

  /// `Last Name`
  String get lastName {
    return Intl.message('Last Name', name: 'lastName', desc: '', args: []);
  }

  /// `Country`
  String get country {
    return Intl.message('Country', name: 'country', desc: '', args: []);
  }

  /// `Bangladesh`
  String get bangladesh {
    return Intl.message('Bangladesh', name: 'bangladesh', desc: '', args: []);
  }

  /// `Apply`
  String get apply {
    return Intl.message('Apply', name: 'apply', desc: '', args: []);
  }

  /// `Delivery Address`
  String get deliveryAddress {
    return Intl.message(
      'Delivery Address',
      name: 'deliveryAddress',
      desc: '',
      args: [],
    );
  }

  /// `No data available`
  String get noDataAvailabe {
    return Intl.message(
      'No data available',
      name: 'noDataAvailabe',
      desc: '',
      args: [],
    );
  }

  /// `Add Delivery`
  String get addDelivery {
    return Intl.message(
      'Add Delivery',
      name: 'addDelivery',
      desc: '',
      args: [],
    );
  }

  /// `Description`
  String get description {
    return Intl.message('Description', name: 'description', desc: '', args: []);
  }

  /// `Add Note`
  String get addNote {
    return Intl.message('Add Note', name: 'addNote', desc: '', args: []);
  }

  /// `Image`
  String get image {
    return Intl.message('Image', name: 'image', desc: '', args: []);
  }

  /// `Please connect the printer first`
  String get pleaseConnectThePrinterFirst {
    return Intl.message(
      'Please connect the printer first',
      name: 'pleaseConnectThePrinterFirst',
      desc: '',
      args: [],
    );
  }

  /// `Select Category`
  String get selectCategory {
    return Intl.message(
      'Select Category',
      name: 'selectCategory',
      desc: '',
      args: [],
    );
  }

  /// `Enter expense date`
  String get enterExpenseDate {
    return Intl.message(
      'Enter expense date',
      name: 'enterExpenseDate',
      desc: '',
      args: [],
    );
  }

  /// `Enter Name`
  String get enterName {
    return Intl.message('Enter Name', name: 'enterName', desc: '', args: []);
  }

  /// `Enter Amount`
  String get enterAmount {
    return Intl.message(
      'Enter Amount',
      name: 'enterAmount',
      desc: '',
      args: [],
    );
  }

  /// `Enter reference number`
  String get enterRefNumber {
    return Intl.message(
      'Enter reference number',
      name: 'enterRefNumber',
      desc: '',
      args: [],
    );
  }

  /// `Fashion`
  String get fashions {
    return Intl.message('Fashion', name: 'fashions', desc: '', args: []);
  }

  /// `Bill To`
  String get billTO {
    return Intl.message('Bill To', name: 'billTO', desc: '', args: []);
  }

  /// `Total Due`
  String get totalDue {
    return Intl.message('Total Due', name: 'totalDue', desc: '', args: []);
  }

  /// `Payment Amounts`
  String get paymentsAmount {
    return Intl.message(
      'Payment Amounts',
      name: 'paymentsAmount',
      desc: '',
      args: [],
    );
  }

  /// `Remaining Due`
  String get remainingDue {
    return Intl.message(
      'Remaining Due',
      name: 'remainingDue',
      desc: '',
      args: [],
    );
  }

  /// `Thank you for your due payment`
  String get thankYouForYourDuePayment {
    return Intl.message(
      'Thank you for your due payment',
      name: 'thankYouForYourDuePayment',
      desc: '',
      args: [],
    );
  }

  /// `Print`
  String get print {
    return Intl.message('Print', name: 'print', desc: '', args: []);
  }

  /// `Unit Price`
  String get unitPirce {
    return Intl.message('Unit Price', name: 'unitPirce', desc: '', args: []);
  }

  /// `Total Price`
  String get totalPrice {
    return Intl.message('Total Price', name: 'totalPrice', desc: '', args: []);
  }

  /// `Total Vat`
  String get totalVat {
    return Intl.message('Total Vat', name: 'totalVat', desc: '', args: []);
  }

  /// `Delivery Charge`
  String get deliveryCharge {
    return Intl.message(
      'Delivery Charge',
      name: 'deliveryCharge',
      desc: '',
      args: [],
    );
  }

  /// `Total Payable`
  String get totalPayable {
    return Intl.message(
      'Total Payable',
      name: 'totalPayable',
      desc: '',
      args: [],
    );
  }

  /// `Thak you for your purchase`
  String get thakYouForYourPurchase {
    return Intl.message(
      'Thak you for your purchase',
      name: 'thakYouForYourPurchase',
      desc: '',
      args: [],
    );
  }

  /// `Please connect your bluetooth printer`
  String get pleaseConnectYourBlutohPrinter {
    return Intl.message(
      'Please connect your bluetooth printer',
      name: 'pleaseConnectYourBlutohPrinter',
      desc: '',
      args: [],
    );
  }

  /// `Edit Socail Media`
  String get editSocailMedia {
    return Intl.message(
      'Edit Socail Media',
      name: 'editSocailMedia',
      desc: '',
      args: [],
    );
  }

  /// `Social Marketing`
  String get socialMarketing {
    return Intl.message(
      'Social Marketing',
      name: 'socialMarketing',
      desc: '',
      args: [],
    );
  }

  /// `Share`
  String get share {
    return Intl.message('Share', name: 'share', desc: '', args: []);
  }

  /// `Notification`
  String get notification {
    return Intl.message(
      'Notification',
      name: 'notification',
      desc: '',
      args: [],
    );
  }

  /// `Purchase Alarm`
  String get purchaseAlarm {
    return Intl.message(
      'Purchase Alarm',
      name: 'purchaseAlarm',
      desc: '',
      args: [],
    );
  }

  /// `Purchase Confirmed`
  String get purchaseConfirmed {
    return Intl.message(
      'Purchase Confirmed',
      name: 'purchaseConfirmed',
      desc: '',
      args: [],
    );
  }

  /// `Payment Complete`
  String get paymentComplete {
    return Intl.message(
      'Payment Complete',
      name: 'paymentComplete',
      desc: '',
      args: [],
    );
  }

  /// `Return`
  String get retur {
    return Intl.message('Return', name: 'retur', desc: '', args: []);
  }

  /// `Send Sms`
  String get sendSms {
    return Intl.message('Send Sms', name: 'sendSms', desc: '', args: []);
  }

  /// `Received the Pin`
  String get recivethePin {
    return Intl.message(
      'Received the Pin',
      name: 'recivethePin',
      desc: '',
      args: [],
    );
  }

  /// `Start New Sale`
  String get startNewSale {
    return Intl.message(
      'Start New Sale',
      name: 'startNewSale',
      desc: '',
      args: [],
    );
  }

  /// `Payment`
  String get payment {
    return Intl.message('Payment', name: 'payment', desc: '', args: []);
  }

  /// `Master Card`
  String get masterCard {
    return Intl.message('Master Card', name: 'masterCard', desc: '', args: []);
  }

  /// `Instruction`
  String get instrucation {
    return Intl.message(
      'Instruction',
      name: 'instrucation',
      desc: '',
      args: [],
    );
  }

  /// `Cash`
  String get cash {
    return Intl.message('Cash', name: 'cash', desc: '', args: []);
  }

  /// `Invoice viewer`
  String get invoiceViewr {
    return Intl.message(
      'Invoice viewer',
      name: 'invoiceViewr',
      desc: '',
      args: [],
    );
  }

  /// `Size`
  String get size {
    return Intl.message('Size', name: 'size', desc: '', args: []);
  }

  /// `Color`
  String get color {
    return Intl.message('Color', name: 'color', desc: '', args: []);
  }

  /// `Weight`
  String get weight {
    return Intl.message('Weight', name: 'weight', desc: '', args: []);
  }

  /// `Capacity`
  String get capacity {
    return Intl.message('Capacity', name: 'capacity', desc: '', args: []);
  }

  /// `Type`
  String get type {
    return Intl.message('Type', name: 'type', desc: '', args: []);
  }

  /// `You want to delete this product?`
  String get youWantTodeletetheProduct {
    return Intl.message(
      'You want to delete this product?',
      name: 'youWantTodeletetheProduct',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get delete {
    return Intl.message('Delete', name: 'delete', desc: '', args: []);
  }

  /// `Contact Details`
  String get contactDetials {
    return Intl.message(
      'Contact Details',
      name: 'contactDetials',
      desc: '',
      args: [],
    );
  }

  /// `Clarence`
  String get clarence {
    return Intl.message('Clarence', name: 'clarence', desc: '', args: []);
  }

  /// `Call`
  String get call {
    return Intl.message('Call', name: 'call', desc: '', args: []);
  }

  /// `Message`
  String get messege {
    return Intl.message('Message', name: 'messege', desc: '', args: []);
  }

  /// `Daily Transaction`
  String get dailyTransaction {
    return Intl.message(
      'Daily Transaction',
      name: 'dailyTransaction',
      desc: '',
      args: [],
    );
  }

  /// `Promo`
  String get promo {
    return Intl.message('Promo', name: 'promo', desc: '', args: []);
  }

  /// `Send`
  String get send {
    return Intl.message('Send', name: 'send', desc: '', args: []);
  }

  /// `Easy to use mobile pos`
  String get easyToUseThePos {
    return Intl.message(
      'Easy to use mobile pos',
      name: 'easyToUseThePos',
      desc: '',
      args: [],
    );
  }

  /// `POSpro app is free, easy to use. In fact, it's one of the best  POS systems around the world.`
  String get easytheusedesciption {
    return Intl.message(
      'POSpro app is free, easy to use. In fact, it\'s one of the best  POS systems around the world.',
      name: 'easytheusedesciption',
      desc: '',
      args: [],
    );
  }

  /// `Chose Your Features`
  String get choseYourFeature {
    return Intl.message(
      'Chose Your Features',
      name: 'choseYourFeature',
      desc: '',
      args: [],
    );
  }

  /// `Features are the important part which makes POSpro different from traditional solutions.`
  String get choseyourfeatureDesciption {
    return Intl.message(
      'Features are the important part which makes POSpro different from traditional solutions.',
      name: 'choseyourfeatureDesciption',
      desc: '',
      args: [],
    );
  }

  /// `All business solutions`
  String get allBusinessSolutions {
    return Intl.message(
      'All business solutions',
      name: 'allBusinessSolutions',
      desc: '',
      args: [],
    );
  }

  /// `PosPro is a complete business solution with stock, account, sales, expense & loss/profit.`
  String get allBusinessolutionDescrip {
    return Intl.message(
      'PosPro is a complete business solution with stock, account, sales, expense & loss/profit.',
      name: 'allBusinessolutionDescrip',
      desc: '',
      args: [],
    );
  }

  /// `Skip`
  String get skip {
    return Intl.message('Skip', name: 'skip', desc: '', args: []);
  }

  /// `Next`
  String get next {
    return Intl.message('Next', name: 'next', desc: '', args: []);
  }

  /// `A new update available\nPlease update your app`
  String get anewUpdateAvailable {
    return Intl.message(
      'A new update available\nPlease update your app',
      name: 'anewUpdateAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Skip the update`
  String get skipTheUpdate {
    return Intl.message(
      'Skip the update',
      name: 'skipTheUpdate',
      desc: '',
      args: [],
    );
  }

  /// `Remember me later`
  String get rememberMeLater {
    return Intl.message(
      'Remember me later',
      name: 'rememberMeLater',
      desc: '',
      args: [],
    );
  }

  /// `Powered By Acnoo`
  String get powerdedByAcnoo {
    return Intl.message(
      'Powered By Acnoo',
      name: 'powerdedByAcnoo',
      desc: '',
      args: [],
    );
  }

  /// `Loss/Profit`
  String get lossOrProfit {
    return Intl.message(
      'Loss/Profit',
      name: 'lossOrProfit',
      desc: '',
      args: [],
    );
  }

  /// `Expense`
  String get expense {
    return Intl.message('Expense', name: 'expense', desc: '', args: []);
  }

  /// `Parties`
  String get parties {
    return Intl.message('Parties', name: 'parties', desc: '', args: []);
  }

  /// `Home`
  String get home {
    return Intl.message('Home', name: 'home', desc: '', args: []);
  }

  /// `Sales`
  String get sales {
    return Intl.message('Sales', name: 'sales', desc: '', args: []);
  }

  /// `Setting`
  String get setting {
    return Intl.message('Setting', name: 'setting', desc: '', args: []);
  }

  /// `Purchase Now`
  String get purchaseNow {
    return Intl.message(
      'Purchase Now',
      name: 'purchaseNow',
      desc: '',
      args: [],
    );
  }

  /// `Payment Methods`
  String get paymentMethods {
    return Intl.message(
      'Payment Methods',
      name: 'paymentMethods',
      desc: '',
      args: [],
    );
  }

  /// `Update`
  String get update {
    return Intl.message('Update', name: 'update', desc: '', args: []);
  }

  /// `Continue`
  String get continueButton {
    return Intl.message('Continue', name: 'continueButton', desc: '', args: []);
  }

  /// `Name`
  String get name {
    return Intl.message('Name', name: 'name', desc: '', args: []);
  }

  /// `Phone Number`
  String get phone {
    return Intl.message('Phone Number', name: 'phone', desc: '', args: []);
  }

  /// `Email Address`
  String get email {
    return Intl.message('Email Address', name: 'email', desc: '', args: []);
  }

  /// `Address`
  String get address {
    return Intl.message('Address', name: 'address', desc: '', args: []);
  }

  /// `Previous Due`
  String get previousDue {
    return Intl.message(
      'Previous Due',
      name: 'previousDue',
      desc: '',
      args: [],
    );
  }

  /// `Select Your Language`
  String get selectLang {
    return Intl.message(
      'Select Your Language',
      name: 'selectLang',
      desc: '',
      args: [],
    );
  }

  /// `Add Contact`
  String get addContact {
    return Intl.message('Add Contact', name: 'addContact', desc: '', args: []);
  }

  /// `More Info`
  String get moreInfo {
    return Intl.message('More Info', name: 'moreInfo', desc: '', args: []);
  }

  /// `Retailer`
  String get retailer {
    return Intl.message('Retailer', name: 'retailer', desc: '', args: []);
  }

  /// `Dealer`
  String get dealer {
    return Intl.message('Dealer', name: 'dealer', desc: '', args: []);
  }

  /// `Wholesaler`
  String get wholesaler {
    return Intl.message('Wholesaler', name: 'wholesaler', desc: '', args: []);
  }

  /// `Supplier`
  String get supplier {
    return Intl.message('Supplier', name: 'supplier', desc: '', args: []);
  }

  /// `Customer Details`
  String get CustomerDetails {
    return Intl.message(
      'Customer Details',
      name: 'CustomerDetails',
      desc: '',
      args: [],
    );
  }

  /// `Recent Transactions`
  String get recentTransaction {
    return Intl.message(
      'Recent Transactions',
      name: 'recentTransaction',
      desc: '',
      args: [],
    );
  }

  /// `Total Products`
  String get totalProduct {
    return Intl.message(
      'Total Products',
      name: 'totalProduct',
      desc: '',
      args: [],
    );
  }

  /// `Total`
  String get total {
    return Intl.message('Total', name: 'total', desc: '', args: []);
  }

  /// `Paid`
  String get paid {
    return Intl.message('Paid', name: 'paid', desc: '', args: []);
  }

  /// `UnPaid`
  String get unPaid {
    return Intl.message('UnPaid', name: 'unPaid', desc: '', args: []);
  }

  /// `Due`
  String get due {
    return Intl.message('Due', name: 'due', desc: '', args: []);
  }

  /// `Click to connect`
  String get connect {
    return Intl.message(
      'Click to connect',
      name: 'connect',
      desc: '',
      args: [],
    );
  }

  /// `Try Again`
  String get tryAgain {
    return Intl.message('Try Again', name: 'tryAgain', desc: '', args: []);
  }

  /// `Loading`
  String get loading {
    return Intl.message('Loading', name: 'loading', desc: '', args: []);
  }

  /// `View All`
  String get viewAll {
    return Intl.message('View All', name: 'viewAll', desc: '', args: []);
  }

  /// `Parties List`
  String get partyList {
    return Intl.message('Parties List', name: 'partyList', desc: '', args: []);
  }

  /// `Please Add A Customer`
  String get addCustomer {
    return Intl.message(
      'Please Add A Customer',
      name: 'addCustomer',
      desc: '',
      args: [],
    );
  }

  /// `Update Contact`
  String get updateContact {
    return Intl.message(
      'Update Contact',
      name: 'updateContact',
      desc: '',
      args: [],
    );
  }

  /// `Due List`
  String get dueList {
    return Intl.message('Due List', name: 'dueList', desc: '', args: []);
  }

  /// `Collect Due`
  String get collectDue {
    return Intl.message('Collect Due', name: 'collectDue', desc: '', args: []);
  }

  /// `Date`
  String get date {
    return Intl.message('Date', name: 'date', desc: '', args: []);
  }

  /// `Due Amount: `
  String get dueAmount {
    return Intl.message('Due Amount: ', name: 'dueAmount', desc: '', args: []);
  }

  /// `Customer Name`
  String get customerName {
    return Intl.message(
      'Customer Name',
      name: 'customerName',
      desc: '',
      args: [],
    );
  }

  /// `Total Amount`
  String get totalAmount {
    return Intl.message(
      'Total Amount',
      name: 'totalAmount',
      desc: '',
      args: [],
    );
  }

  /// `Paid Amount`
  String get paidAmount {
    return Intl.message('Paid Amount', name: 'paidAmount', desc: '', args: []);
  }

  /// `Payment Type`
  String get paymentTypes {
    return Intl.message(
      'Payment Type',
      name: 'paymentTypes',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message('Cancel', name: 'cancel', desc: '', args: []);
  }

  /// `Expense Report`
  String get expenseReport {
    return Intl.message(
      'Expense Report',
      name: 'expenseReport',
      desc: '',
      args: [],
    );
  }

  /// `From Date`
  String get fromDate {
    return Intl.message('From Date', name: 'fromDate', desc: '', args: []);
  }

  /// `To Date`
  String get toDate {
    return Intl.message('To Date', name: 'toDate', desc: '', args: []);
  }

  /// `Expense For`
  String get expenseFor {
    return Intl.message('Expense For', name: 'expenseFor', desc: '', args: []);
  }

  /// `Amount`
  String get amount {
    return Intl.message('Amount', name: 'amount', desc: '', args: []);
  }

  /// `No Data Available`
  String get noData {
    return Intl.message(
      'No Data Available',
      name: 'noData',
      desc: '',
      args: [],
    );
  }

  /// `Total Expense`
  String get totalExpense {
    return Intl.message(
      'Total Expense',
      name: 'totalExpense',
      desc: '',
      args: [],
    );
  }

  /// `Add Expense`
  String get addExpense {
    return Intl.message('Add Expense', name: 'addExpense', desc: '', args: []);
  }

  /// `Expense Date`
  String get expenseDate {
    return Intl.message(
      'Expense Date',
      name: 'expenseDate',
      desc: '',
      args: [],
    );
  }

  /// `Reference Number`
  String get referenceNo {
    return Intl.message(
      'Reference Number',
      name: 'referenceNo',
      desc: '',
      args: [],
    );
  }

  /// `Note`
  String get note {
    return Intl.message('Note', name: 'note', desc: '', args: []);
  }

  /// `Expense Categories`
  String get expenseCat {
    return Intl.message(
      'Expense Categories',
      name: 'expenseCat',
      desc: '',
      args: [],
    );
  }

  /// `Search`
  String get search {
    return Intl.message('Search', name: 'search', desc: '', args: []);
  }

  /// `Select`
  String get select {
    return Intl.message('Select', name: 'select', desc: '', args: []);
  }

  /// `Add Expense Category`
  String get addExpenseCat {
    return Intl.message(
      'Add Expense Category',
      name: 'addExpenseCat',
      desc: '',
      args: [],
    );
  }

  /// `Category name`
  String get categoryName {
    return Intl.message(
      'Category name',
      name: 'categoryName',
      desc: '',
      args: [],
    );
  }

  /// `Already Added`
  String get alreadyAdded {
    return Intl.message(
      'Already Added',
      name: 'alreadyAdded',
      desc: '',
      args: [],
    );
  }

  /// `What's New`
  String get whatNew {
    return Intl.message('What\'s New', name: 'whatNew', desc: '', args: []);
  }

  /// `Loss/Profit`
  String get lp {
    return Intl.message('Loss/Profit', name: 'lp', desc: '', args: []);
  }

  /// `Profit`
  String get profit {
    return Intl.message('Profit', name: 'profit', desc: '', args: []);
  }

  /// `Loss`
  String get loss {
    return Intl.message('Loss', name: 'loss', desc: '', args: []);
  }

  /// `Loss/Profit Details`
  String get lpDetails {
    return Intl.message(
      'Loss/Profit Details',
      name: 'lpDetails',
      desc: '',
      args: [],
    );
  }

  /// `Invoice`
  String get invoice {
    return Intl.message('Invoice', name: 'invoice', desc: '', args: []);
  }

  /// `Date:`
  String get dates {
    return Intl.message('Date:', name: 'dates', desc: '', args: []);
  }

  /// `Mobile:`
  String get mobile {
    return Intl.message('Mobile:', name: 'mobile', desc: '', args: []);
  }

  /// `Product`
  String get product {
    return Intl.message('Product', name: 'product', desc: '', args: []);
  }

  /// `Quantity`
  String get quantity {
    return Intl.message('Quantity', name: 'quantity', desc: '', args: []);
  }

  /// `Discount`
  String get discount {
    return Intl.message('Discount', name: 'discount', desc: '', args: []);
  }

  /// `Total Loss`
  String get totalLoss {
    return Intl.message('Total Loss', name: 'totalLoss', desc: '', args: []);
  }

  /// `Total Profit`
  String get totalProfit {
    return Intl.message(
      'Total Profit',
      name: 'totalProfit',
      desc: '',
      args: [],
    );
  }

  /// `Product List`
  String get productList {
    return Intl.message(
      'Product List',
      name: 'productList',
      desc: '',
      args: [],
    );
  }

  /// `Stock`
  String get stock {
    return Intl.message('Stock', name: 'stock', desc: '', args: []);
  }

  /// `Add New Product`
  String get addNewProduct {
    return Intl.message(
      'Add New Product',
      name: 'addNewProduct',
      desc: '',
      args: [],
    );
  }

  /// `Product name`
  String get productName {
    return Intl.message(
      'Product name',
      name: 'productName',
      desc: '',
      args: [],
    );
  }

  /// `Product Code`
  String get productCode {
    return Intl.message(
      'Product Code',
      name: 'productCode',
      desc: '',
      args: [],
    );
  }

  /// `Purchase Price`
  String get purchasePrice {
    return Intl.message(
      'Purchase Price',
      name: 'purchasePrice',
      desc: '',
      args: [],
    );
  }

  /// `MRP`
  String get mrp {
    return Intl.message('MRP', name: 'mrp', desc: '', args: []);
  }

  /// `WholeSale Price`
  String get wholeSalePrice {
    return Intl.message(
      'WholeSale Price',
      name: 'wholeSalePrice',
      desc: '',
      args: [],
    );
  }

  /// `Dealer price`
  String get dealerPrice {
    return Intl.message(
      'Dealer price',
      name: 'dealerPrice',
      desc: '',
      args: [],
    );
  }

  /// `Manufacturer`
  String get manufacturer {
    return Intl.message(
      'Manufacturer',
      name: 'manufacturer',
      desc: '',
      args: [],
    );
  }

  /// `Save and Publish`
  String get saveNPublish {
    return Intl.message(
      'Save and Publish',
      name: 'saveNPublish',
      desc: '',
      args: [],
    );
  }

  /// `Brands`
  String get brands {
    return Intl.message('Brands', name: 'brands', desc: '', args: []);
  }

  /// `Add Brand`
  String get addBrand {
    return Intl.message('Add Brand', name: 'addBrand', desc: '', args: []);
  }

  /// `Brand name`
  String get brandName {
    return Intl.message('Brand name', name: 'brandName', desc: '', args: []);
  }

  /// `Add Unit`
  String get addUnit {
    return Intl.message('Add Unit', name: 'addUnit', desc: '', args: []);
  }

  /// `Unit name`
  String get unitName {
    return Intl.message('Unit name', name: 'unitName', desc: '', args: []);
  }

  /// `Units`
  String get units {
    return Intl.message('Units', name: 'units', desc: '', args: []);
  }

  /// `Please Add A Product`
  String get addProduct {
    return Intl.message(
      'Please Add A Product',
      name: 'addProduct',
      desc: '',
      args: [],
    );
  }

  /// `Update Product`
  String get updateProduct {
    return Intl.message(
      'Update Product',
      name: 'updateProduct',
      desc: '',
      args: [],
    );
  }

  /// `Sale Price`
  String get salePrice {
    return Intl.message('Sale Price', name: 'salePrice', desc: '', args: []);
  }

  /// `Profile`
  String get profile {
    return Intl.message('Profile', name: 'profile', desc: '', args: []);
  }

  /// `Edit`
  String get edit {
    return Intl.message('Edit', name: 'edit', desc: '', args: []);
  }

  /// `Business Category`
  String get businessCat {
    return Intl.message(
      'Business Category',
      name: 'businessCat',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get language {
    return Intl.message('Language', name: 'language', desc: '', args: []);
  }

  /// `Change Password`
  String get changePassword {
    return Intl.message(
      'Change Password',
      name: 'changePassword',
      desc: '',
      args: [],
    );
  }

  /// `Update Your Profile`
  String get updateProfile {
    return Intl.message(
      'Update Your Profile',
      name: 'updateProfile',
      desc: '',
      args: [],
    );
  }

  /// `Company & Business Name`
  String get businessName {
    return Intl.message(
      'Company & Business Name',
      name: 'businessName',
      desc: '',
      args: [],
    );
  }

  /// `Add Purchase`
  String get addPurchase {
    return Intl.message(
      'Add Purchase',
      name: 'addPurchase',
      desc: '',
      args: [],
    );
  }

  /// `Inv No`
  String get inv {
    return Intl.message('Inv No', name: 'inv', desc: '', args: []);
  }

  /// `Supplier Name`
  String get supplierName {
    return Intl.message(
      'Supplier Name',
      name: 'supplierName',
      desc: '',
      args: [],
    );
  }

  /// `Item Added`
  String get itemAdded {
    return Intl.message('Item Added', name: 'itemAdded', desc: '', args: []);
  }

  /// `Add Items`
  String get addItems {
    return Intl.message('Add Items', name: 'addItems', desc: '', args: []);
  }

  /// `Sub Total`
  String get subTotal {
    return Intl.message('Sub Total', name: 'subTotal', desc: '', args: []);
  }

  /// `Return Amount`
  String get returnAmount {
    return Intl.message(
      'Return Amount',
      name: 'returnAmount',
      desc: '',
      args: [],
    );
  }

  /// `Choose a Supplier`
  String get chooseSupplier {
    return Intl.message(
      'Choose a Supplier',
      name: 'chooseSupplier',
      desc: '',
      args: [],
    );
  }

  /// `No Supplier Available`
  String get noSupplier {
    return Intl.message(
      'No Supplier Available',
      name: 'noSupplier',
      desc: '',
      args: [],
    );
  }

  /// `Sales Details`
  String get salesDetails {
    return Intl.message(
      'Sales Details',
      name: 'salesDetails',
      desc: '',
      args: [],
    );
  }

  /// `Edit Purchase Invoice`
  String get editPurchaseInvoice {
    return Intl.message(
      'Edit Purchase Invoice',
      name: 'editPurchaseInvoice',
      desc: '',
      args: [],
    );
  }

  /// `Purchase List`
  String get purchaseList {
    return Intl.message(
      'Purchase List',
      name: 'purchaseList',
      desc: '',
      args: [],
    );
  }

  /// `Please Add A Purchase`
  String get addAPurchase {
    return Intl.message(
      'Please Add A Purchase',
      name: 'addAPurchase',
      desc: '',
      args: [],
    );
  }

  /// `Due Report`
  String get dueReport {
    return Intl.message('Due Report', name: 'dueReport', desc: '', args: []);
  }

  /// `Fully Paid`
  String get fullyPaid {
    return Intl.message('Fully Paid', name: 'fullyPaid', desc: '', args: []);
  }

  /// `Still Unpaid`
  String get stillUnpaid {
    return Intl.message(
      'Still Unpaid',
      name: 'stillUnpaid',
      desc: '',
      args: [],
    );
  }

  /// `Purchase Report`
  String get purchaseReport {
    return Intl.message(
      'Purchase Report',
      name: 'purchaseReport',
      desc: '',
      args: [],
    );
  }

  /// `Connect your printer`
  String get connectPrinter {
    return Intl.message(
      'Connect your printer',
      name: 'connectPrinter',
      desc: '',
      args: [],
    );
  }

  /// `Click to connect`
  String get clickToConnect {
    return Intl.message(
      'Click to connect',
      name: 'clickToConnect',
      desc: '',
      args: [],
    );
  }

  /// `Please Collect A Due`
  String get collectDues {
    return Intl.message(
      'Please Collect A Due',
      name: 'collectDues',
      desc: '',
      args: [],
    );
  }

  /// `Please Add A Purchase`
  String get addNewPurchase {
    return Intl.message(
      'Please Add A Purchase',
      name: 'addNewPurchase',
      desc: '',
      args: [],
    );
  }

  /// `Sales Report`
  String get salesReport {
    return Intl.message(
      'Sales Report',
      name: 'salesReport',
      desc: '',
      args: [],
    );
  }

  /// `Please Add A Sale`
  String get addSale {
    return Intl.message(
      'Please Add A Sale',
      name: 'addSale',
      desc: '',
      args: [],
    );
  }

  /// `Reports`
  String get reports {
    return Intl.message('Reports', name: 'reports', desc: '', args: []);
  }

  /// `Choose a Customer`
  String get chooseCustomer {
    return Intl.message(
      'Choose a Customer',
      name: 'chooseCustomer',
      desc: '',
      args: [],
    );
  }

  /// `Add Sales`
  String get addSales {
    return Intl.message('Add Sales', name: 'addSales', desc: '', args: []);
  }

  /// `Sales List`
  String get saleList {
    return Intl.message('Sales List', name: 'saleList', desc: '', args: []);
  }

  /// `Edit Sales Invoice`
  String get editSalesInvoice {
    return Intl.message(
      'Edit Sales Invoice',
      name: 'editSalesInvoice',
      desc: '',
      args: [],
    );
  }

  /// `Previous Pay Amount`
  String get previousPayAmount {
    return Intl.message(
      'Previous Pay Amount',
      name: 'previousPayAmount',
      desc: '',
      args: [],
    );
  }

  /// `Printing Option`
  String get printing {
    return Intl.message(
      'Printing Option',
      name: 'printing',
      desc: '',
      args: [],
    );
  }

  /// `Subscription`
  String get subscription {
    return Intl.message(
      'Subscription',
      name: 'subscription',
      desc: '',
      args: [],
    );
  }

  /// `User Role`
  String get userRole {
    return Intl.message('User Role', name: 'userRole', desc: '', args: []);
  }

  /// `Currency`
  String get currency {
    return Intl.message('Currency', name: 'currency', desc: '', args: []);
  }

  /// `Log Out`
  String get logOut {
    return Intl.message('Log Out', name: 'logOut', desc: '', args: []);
  }

  /// `Stock List`
  String get stockList {
    return Intl.message('Stock List', name: 'stockList', desc: '', args: []);
  }

  /// `Purchase`
  String get purchase {
    return Intl.message('Purchase', name: 'purchase', desc: '', args: []);
  }

  /// `Sale`
  String get sale {
    return Intl.message('Sale', name: 'sale', desc: '', args: []);
  }

  /// `Your Package`
  String get yourPack {
    return Intl.message('Your Package', name: 'yourPack', desc: '', args: []);
  }

  /// `Free Plan`
  String get freePlan {
    return Intl.message('Free Plan', name: 'freePlan', desc: '', args: []);
  }

  /// `You are using `
  String get youRUsing {
    return Intl.message(
      'You are using ',
      name: 'youRUsing',
      desc: '',
      args: [],
    );
  }

  /// `Free Package`
  String get freePack {
    return Intl.message('Free Package', name: 'freePack', desc: '', args: []);
  }

  /// `Premium Plan`
  String get premiumPlan {
    return Intl.message(
      'Premium Plan',
      name: 'premiumPlan',
      desc: '',
      args: [],
    );
  }

  /// `Package Features`
  String get packFeatures {
    return Intl.message(
      'Package Features',
      name: 'packFeatures',
      desc: '',
      args: [],
    );
  }

  /// `Unlimited`
  String get unlimited {
    return Intl.message('Unlimited', name: 'unlimited', desc: '', args: []);
  }

  /// `Update Now`
  String get updateNow {
    return Intl.message('Update Now', name: 'updateNow', desc: '', args: []);
  }

  /// `Purchase Premium Plan`
  String get purchasePremium {
    return Intl.message(
      'Purchase Premium Plan',
      name: 'purchasePremium',
      desc: '',
      args: [],
    );
  }

  /// `Buy premium Plan`
  String get buyPremium {
    return Intl.message(
      'Buy premium Plan',
      name: 'buyPremium',
      desc: '',
      args: [],
    );
  }

  /// `Pay With Paypal`
  String get paypalPay {
    return Intl.message(
      'Pay With Paypal',
      name: 'paypalPay',
      desc: '',
      args: [],
    );
  }

  /// `You Have Got An Email`
  String get gotEmail {
    return Intl.message(
      'You Have Got An Email',
      name: 'gotEmail',
      desc: '',
      args: [],
    );
  }

  /// `We Have Send An Email with instructions on how to reset password to:`
  String get sendEmail {
    return Intl.message(
      'We Have Send An Email with instructions on how to reset password to:',
      name: 'sendEmail',
      desc: '',
      args: [],
    );
  }

  /// `Check Email`
  String get checkEmail {
    return Intl.message('Check Email', name: 'checkEmail', desc: '', args: []);
  }

  /// `Close`
  String get close {
    return Intl.message('Close', name: 'close', desc: '', args: []);
  }

  /// `Please enter your email address below to receive password Reset Link.`
  String get enterEmail {
    return Intl.message(
      'Please enter your email address below to receive password Reset Link.',
      name: 'enterEmail',
      desc: '',
      args: [],
    );
  }

  /// `Send Reset Link`
  String get sendLink {
    return Intl.message(
      'Send Reset Link',
      name: 'sendLink',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get emailText {
    return Intl.message('Email', name: 'emailText', desc: '', args: []);
  }

  /// `Password`
  String get password {
    return Intl.message('Password', name: 'password', desc: '', args: []);
  }

  /// `Haven't any account?`
  String get noAcc {
    return Intl.message(
      'Haven\'t any account?',
      name: 'noAcc',
      desc: '',
      args: [],
    );
  }

  /// `Register`
  String get register {
    return Intl.message('Register', name: 'register', desc: '', args: []);
  }

  /// `Phone Verification`
  String get phoneVerification {
    return Intl.message(
      'Phone Verification',
      name: 'phoneVerification',
      desc: '',
      args: [],
    );
  }

  /// `We need to register your phone without getting started!`
  String get registerTitle {
    return Intl.message(
      'We need to register your phone without getting started!',
      name: 'registerTitle',
      desc: '',
      args: [],
    );
  }

  /// `Send the code`
  String get sendCode {
    return Intl.message('Send the code', name: 'sendCode', desc: '', args: []);
  }

  /// `Staff Login`
  String get staffLogin {
    return Intl.message('Staff Login', name: 'staffLogin', desc: '', args: []);
  }

  /// `Login With Email`
  String get logInWithMail {
    return Intl.message(
      'Login With Email',
      name: 'logInWithMail',
      desc: '',
      args: [],
    );
  }

  /// `Setup Your Profile`
  String get setUpProfile {
    return Intl.message(
      'Setup Your Profile',
      name: 'setUpProfile',
      desc: '',
      args: [],
    );
  }

  /// `Update your profile to connect your doctor with better impression`
  String get setUpDesc {
    return Intl.message(
      'Update your profile to connect your doctor with better impression',
      name: 'setUpDesc',
      desc: '',
      args: [],
    );
  }

  /// `Gallery`
  String get gallery {
    return Intl.message('Gallery', name: 'gallery', desc: '', args: []);
  }

  /// `Camera`
  String get camera {
    return Intl.message('Camera', name: 'camera', desc: '', args: []);
  }

  /// `Company Address`
  String get companyAddress {
    return Intl.message(
      'Company Address',
      name: 'companyAddress',
      desc: '',
      args: [],
    );
  }

  /// `Opening Balance`
  String get openingBalance {
    return Intl.message(
      'Opening Balance',
      name: 'openingBalance',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Password`
  String get confirmPass {
    return Intl.message(
      'Confirm Password',
      name: 'confirmPass',
      desc: '',
      args: [],
    );
  }

  /// `Already have an account?`
  String get haveAcc {
    return Intl.message(
      'Already have an account?',
      name: 'haveAcc',
      desc: '',
      args: [],
    );
  }

  /// `Login With Phone`
  String get loginWithPhone {
    return Intl.message(
      'Login With Phone',
      name: 'loginWithPhone',
      desc: '',
      args: [],
    );
  }

  /// `Edit Phone Number ?`
  String get editPhone {
    return Intl.message(
      'Edit Phone Number ?',
      name: 'editPhone',
      desc: '',
      args: [],
    );
  }

  /// `Create a Free Account`
  String get createAcc {
    return Intl.message(
      'Create a Free Account',
      name: 'createAcc',
      desc: '',
      args: [],
    );
  }

  /// `Congratulations`
  String get congratulation {
    return Intl.message(
      'Congratulations',
      name: 'congratulation',
      desc: '',
      args: [],
    );
  }

  /// `Sign in`
  String get signIn {
    return Intl.message('Sign in', name: 'signIn', desc: '', args: []);
  }

  /// `Log In`
  String get logIn {
    return Intl.message('Log In', name: 'logIn', desc: '', args: []);
  }

  /// `Welcome back!`
  String get welcomeBack {
    return Intl.message(
      'Welcome back!',
      name: 'welcomeBack',
      desc: '',
      args: [],
    );
  }

  /// `Password can't be empty`
  String get passwordCannotBeEmpty {
    return Intl.message(
      'Password can\'t be empty',
      name: 'passwordCannotBeEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get save {
    return Intl.message('Save', name: 'save', desc: '', args: []);
  }

  /// `Forgot password`
  String get forgotPassword {
    return Intl.message(
      'Forgot password',
      name: 'forgotPassword',
      desc: '',
      args: [],
    );
  }

  /// `Reset password by using your email or phone number`
  String get reset {
    return Intl.message(
      'Reset password by using your email or phone number',
      name: 'reset',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get lableEmail {
    return Intl.message('Email', name: 'lableEmail', desc: '', args: []);
  }

  /// `Enter email address`
  String get hintEmail {
    return Intl.message(
      'Enter email address',
      name: 'hintEmail',
      desc: '',
      args: [],
    );
  }

  /// `Email can't be empty`
  String get emailCannotBeEmpty {
    return Intl.message(
      'Email can\'t be empty',
      name: 'emailCannotBeEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid email`
  String get pleaseEnterAValidEmail {
    return Intl.message(
      'Please enter a valid email',
      name: 'pleaseEnterAValidEmail',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get continueE {
    return Intl.message('Continue', name: 'continueE', desc: '', args: []);
  }

  /// `Please enter your details.`
  String get pleaseEnterYourDetails {
    return Intl.message(
      'Please enter your details.',
      name: 'pleaseEnterYourDetails',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get lablePassword {
    return Intl.message('Password', name: 'lablePassword', desc: '', args: []);
  }

  /// `Enter password`
  String get hintPassword {
    return Intl.message(
      'Enter password',
      name: 'hintPassword',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a bigger password`
  String get pleaseEnterABiggerPassword {
    return Intl.message(
      'Please enter a bigger password',
      name: 'pleaseEnterABiggerPassword',
      desc: '',
      args: [],
    );
  }

  /// `Remember me`
  String get rememberMe {
    return Intl.message('Remember me', name: 'rememberMe', desc: '', args: []);
  }

  /// `Don’t have an account?`
  String get donNotHaveAnAccount {
    return Intl.message(
      'Don’t have an account?',
      name: 'donNotHaveAnAccount',
      desc: '',
      args: [],
    );
  }

  /// `Create A Free Account`
  String get createAFreeAccount {
    return Intl.message(
      'Create A Free Account',
      name: 'createAFreeAccount',
      desc: '',
      args: [],
    );
  }

  /// `Full Name`
  String get fullName {
    return Intl.message('Full Name', name: 'fullName', desc: '', args: []);
  }

  /// `Enter your full name`
  String get enterYourFullName {
    return Intl.message(
      'Enter your full name',
      name: 'enterYourFullName',
      desc: '',
      args: [],
    );
  }

  /// `name can'n be empty`
  String get nameCanNotBeEmpty {
    return Intl.message(
      'name can\'n be empty',
      name: 'nameCanNotBeEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Already have an account? `
  String get alreadyHaveAnAccount {
    return Intl.message(
      'Already have an account? ',
      name: 'alreadyHaveAnAccount',
      desc: '',
      args: [],
    );
  }

  /// `Create New Password`
  String get createNewPassword {
    return Intl.message(
      'Create New Password',
      name: 'createNewPassword',
      desc: '',
      args: [],
    );
  }

  /// `Set Up New Password`
  String get setUpNewPassword {
    return Intl.message(
      'Set Up New Password',
      name: 'setUpNewPassword',
      desc: '',
      args: [],
    );
  }

  /// `Reset your password to recovery and log in your account`
  String get resetPassword {
    return Intl.message(
      'Reset your password to recovery and log in your account',
      name: 'resetPassword',
      desc: '',
      args: [],
    );
  }

  /// `New Password`
  String get newPassword {
    return Intl.message(
      'New Password',
      name: 'newPassword',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Password`
  String get confirmPassword {
    return Intl.message(
      'Confirm Password',
      name: 'confirmPassword',
      desc: '',
      args: [],
    );
  }

  /// `Passwords do not match`
  String get passwordsDoNotMatch {
    return Intl.message(
      'Passwords do not match',
      name: 'passwordsDoNotMatch',
      desc: '',
      args: [],
    );
  }

  /// `Verity Email`
  String get verityEmail {
    return Intl.message(
      'Verity Email',
      name: 'verityEmail',
      desc: '',
      args: [],
    );
  }

  /// `Verification`
  String get verification {
    return Intl.message(
      'Verification',
      name: 'verification',
      desc: '',
      args: [],
    );
  }

  /// `6-digits pin has been sent to your email address: `
  String get digits {
    return Intl.message(
      '6-digits pin has been sent to your email address: ',
      name: 'digits',
      desc: '',
      args: [],
    );
  }

  /// `Enter valid OTP`
  String get enterValidOTP {
    return Intl.message(
      'Enter valid OTP',
      name: 'enterValidOTP',
      desc: '',
      args: [],
    );
  }

  /// `Enter valid OTP`
  String get resendOTP {
    return Intl.message(
      'Enter valid OTP',
      name: 'resendOTP',
      desc: '',
      args: [],
    );
  }

  /// `Verify Your Email`
  String get verifyYourEmail {
    return Intl.message(
      'Verify Your Email',
      name: 'verifyYourEmail',
      desc: '',
      args: [],
    );
  }

  /// `We have sent a confirmation email to`
  String get weHaveSentAConfirmationEmailTo {
    return Intl.message(
      'We have sent a confirmation email to',
      name: 'weHaveSentAConfirmationEmailTo',
      desc: '',
      args: [],
    );
  }

  /// `It May be that the mail ended up in your spam folder.`
  String get folder {
    return Intl.message(
      'It May be that the mail ended up in your spam folder.',
      name: 'folder',
      desc: '',
      args: [],
    );
  }

  /// `Got It`
  String get gotIt {
    return Intl.message('Got It', name: 'gotIt', desc: '', args: []);
  }

  /// `Enter opening balance`
  String get enterOpeningBalance {
    return Intl.message(
      'Enter opening balance',
      name: 'enterOpeningBalance',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid business name`
  String get pleaseEnterAValidBusinessName {
    return Intl.message(
      'Please enter a valid business name',
      name: 'pleaseEnterAValidBusinessName',
      desc: '',
      args: [],
    );
  }

  /// `Enter Business/Store Name`
  String get enterBusiness {
    return Intl.message(
      'Enter Business/Store Name',
      name: 'enterBusiness',
      desc: '',
      args: [],
    );
  }

  /// `Select Business Category`
  String get selectBusinessCategory {
    return Intl.message(
      'Select Business Category',
      name: 'selectBusinessCategory',
      desc: '',
      args: [],
    );
  }

  /// `Today’s Summary`
  String get todaySummary {
    return Intl.message(
      'Today’s Summary',
      name: 'todaySummary',
      desc: '',
      args: [],
    );
  }

  /// `Sell All >`
  String get sellAll {
    return Intl.message('Sell All >', name: 'sellAll', desc: '', args: []);
  }

  /// `Income`
  String get income {
    return Intl.message('Income', name: 'income', desc: '', args: []);
  }

  /// `Purchased`
  String get purchased {
    return Intl.message('Purchased', name: 'purchased', desc: '', args: []);
  }

  /// `End your Free plan`
  String get endYourFreePlan {
    return Intl.message(
      'End your Free plan',
      name: 'endYourFreePlan',
      desc: '',
      args: [],
    );
  }

  /// `Your Free Package is almost done, buy your next plan Thanks.`
  String get yourFree {
    return Intl.message(
      'Your Free Package is almost done, buy your next plan Thanks.',
      name: 'yourFree',
      desc: '',
      args: [],
    );
  }

  /// `Upgrade Now`
  String get upgradeNow {
    return Intl.message('Upgrade Now', name: 'upgradeNow', desc: '', args: []);
  }

  /// `Not Found`
  String get notFound {
    return Intl.message('Not Found', name: 'notFound', desc: '', args: []);
  }

  /// `Update your subscription`
  String get updateYourSubscription {
    return Intl.message(
      'Update your subscription',
      name: 'updateYourSubscription',
      desc: '',
      args: [],
    );
  }

  /// `No Data Found`
  String get noDataFound {
    return Intl.message(
      'No Data Found',
      name: 'noDataFound',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure?`
  String get areYouSure {
    return Intl.message(
      'Are you sure?',
      name: 'areYouSure',
      desc: '',
      args: [],
    );
  }

  /// `Do you want to exit the app?`
  String get doYouWantToExitTheApp {
    return Intl.message(
      'Do you want to exit the app?',
      name: 'doYouWantToExitTheApp',
      desc: '',
      args: [],
    );
  }

  /// `No`
  String get no {
    return Intl.message('No', name: 'no', desc: '', args: []);
  }

  /// `Yes`
  String get yes {
    return Intl.message('Yes', name: 'yes', desc: '', args: []);
  }

  /// `Dashboard`
  String get dashboard {
    return Intl.message('Dashboard', name: 'dashboard', desc: '', args: []);
  }

  /// `Sales & Purchase Overview`
  String get salesPurchaseOverview {
    return Intl.message(
      'Sales & Purchase Overview',
      name: 'salesPurchaseOverview',
      desc: '',
      args: [],
    );
  }

  /// `Total Items`
  String get totalItems {
    return Intl.message('Total Items', name: 'totalItems', desc: '', args: []);
  }

  /// `Total Categories`
  String get totalCategories {
    return Intl.message(
      'Total Categories',
      name: 'totalCategories',
      desc: '',
      args: [],
    );
  }

  /// `Quick Overview`
  String get quickOverview {
    return Intl.message(
      'Quick Overview',
      name: 'quickOverview',
      desc: '',
      args: [],
    );
  }

  /// `Total Income`
  String get totalIncome {
    return Intl.message(
      'Total Income',
      name: 'totalIncome',
      desc: '',
      args: [],
    );
  }

  /// `Customer Due`
  String get customerDue {
    return Intl.message(
      'Customer Due',
      name: 'customerDue',
      desc: '',
      args: [],
    );
  }

  /// `Stock Value`
  String get stockValue {
    return Intl.message('Stock Value', name: 'stockValue', desc: '', args: []);
  }

  /// `Loss/Profit`
  String get lossProfit {
    return Intl.message('Loss/Profit', name: 'lossProfit', desc: '', args: []);
  }

  /// `Cost`
  String get cost {
    return Intl.message('Cost', name: 'cost', desc: '', args: []);
  }

  /// `Qty`
  String get qty {
    return Intl.message('Qty', name: 'qty', desc: '', args: []);
  }

  /// `No Product Found`
  String get noProductFound {
    return Intl.message(
      'No Product Found',
      name: 'noProductFound',
      desc: '',
      args: [],
    );
  }

  /// `Phone Number`
  String get phoneNumber {
    return Intl.message(
      'Phone Number',
      name: 'phoneNumber',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid Name`
  String get pleaseEnterAValidName {
    return Intl.message(
      'Please enter a valid Name',
      name: 'pleaseEnterAValidName',
      desc: '',
      args: [],
    );
  }

  /// `Please Enter valid phone and name first`
  String get pleaseEnterValidPhoneAndNameFirst {
    return Intl.message(
      'Please Enter valid phone and name first',
      name: 'pleaseEnterValidPhoneAndNameFirst',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Delete`
  String get confirmDelete {
    return Intl.message(
      'Confirm Delete',
      name: 'confirmDelete',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete this party?`
  String get areYouSureYouWant {
    return Intl.message(
      'Are you sure you want to delete this party?',
      name: 'areYouSureYouWant',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid phone number`
  String get pleaseEnterAValidPhoneNumber {
    return Intl.message(
      'Please enter a valid phone number',
      name: 'pleaseEnterAValidPhoneNumber',
      desc: '',
      args: [],
    );
  }

  /// `Send SMS`
  String get sendSMS {
    return Intl.message('Send SMS', name: 'sendSMS', desc: '', args: []);
  }

  /// `Search Here....`
  String get searchH {
    return Intl.message('Search Here....', name: 'searchH', desc: '', args: []);
  }

  /// `Transactions`
  String get transactions {
    return Intl.message(
      'Transactions',
      name: 'transactions',
      desc: '',
      args: [],
    );
  }

  /// `Select a invoice`
  String get selectAInvoice {
    return Intl.message(
      'Select a invoice',
      name: 'selectAInvoice',
      desc: '',
      args: [],
    );
  }

  /// `Total Due amount`
  String get totalDueAmount {
    return Intl.message(
      'Total Due amount',
      name: 'totalDueAmount',
      desc: '',
      args: [],
    );
  }

  /// `You can't pay more then due`
  String get youCanNotPayMoreThenDue {
    return Intl.message(
      'You can\'t pay more then due',
      name: 'youCanNotPayMoreThenDue',
      desc: '',
      args: [],
    );
  }

  /// `No Due Selected`
  String get noDueSelected {
    return Intl.message(
      'No Due Selected',
      name: 'noDueSelected',
      desc: '',
      args: [],
    );
  }

  /// `Please Enter Name`
  String get pleaseEnterName {
    return Intl.message(
      'Please Enter Name',
      name: 'pleaseEnterName',
      desc: '',
      args: [],
    );
  }

  /// `Please Enter Amount`
  String get pleaseEnterAmount {
    return Intl.message(
      'Please Enter Amount',
      name: 'pleaseEnterAmount',
      desc: '',
      args: [],
    );
  }

  /// `Enter Note`
  String get enterNote {
    return Intl.message('Enter Note', name: 'enterNote', desc: '', args: []);
  }

  /// `Please select a expense category`
  String get pleaseSelectAExpenseCategory {
    return Intl.message(
      'Please select a expense category',
      name: 'pleaseSelectAExpenseCategory',
      desc: '',
      args: [],
    );
  }

  /// `Enter expanse category name`
  String get enterExpanseCategoryName {
    return Intl.message(
      'Enter expanse category name',
      name: 'enterExpanseCategoryName',
      desc: '',
      args: [],
    );
  }

  /// `Coming Soon`
  String get comingSoon {
    return Intl.message('Coming Soon', name: 'comingSoon', desc: '', args: []);
  }

  /// `Please make a sale first`
  String get pleaseMakeASaleFirst {
    return Intl.message(
      'Please make a sale first',
      name: 'pleaseMakeASaleFirst',
      desc: '',
      args: [],
    );
  }

  /// `Facebook`
  String get facebook {
    return Intl.message('Facebook', name: 'facebook', desc: '', args: []);
  }

  /// `Twitter`
  String get twitter {
    return Intl.message('Twitter', name: 'twitter', desc: '', args: []);
  }

  /// `Instagram`
  String get instagram {
    return Intl.message('Instagram', name: 'instagram', desc: '', args: []);
  }

  /// `LinkedIN`
  String get linkedIN {
    return Intl.message('LinkedIN', name: 'linkedIN', desc: '', args: []);
  }

  /// `Link`
  String get link {
    return Intl.message('Link', name: 'link', desc: '', args: []);
  }

  /// `Lorem ipsum dolor sit amet, consectetur adip gravi iscing elit. Ultricies gravida scelerisque arcu facilisis duis in.`
  String get lorem {
    return Intl.message(
      'Lorem ipsum dolor sit amet, consectetur adip gravi iscing elit. Ultricies gravida scelerisque arcu facilisis duis in.',
      name: 'lorem',
      desc: '',
      args: [],
    );
  }

  /// `Payment Gateway`
  String get paymentGateway {
    return Intl.message(
      'Payment Gateway',
      name: 'paymentGateway',
      desc: '',
      args: [],
    );
  }

  /// `Payment Success`
  String get paymentSuccess {
    return Intl.message(
      'Payment Success',
      name: 'paymentSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Payment was successful!`
  String get paymentWasSuccessful {
    return Intl.message(
      'Payment was successful!',
      name: 'paymentWasSuccessful',
      desc: '',
      args: [],
    );
  }

  /// `Payment Failed`
  String get paymentFailed {
    return Intl.message(
      'Payment Failed',
      name: 'paymentFailed',
      desc: '',
      args: [],
    );
  }

  /// `Payment failed. Please try again.`
  String get paymentFailedPleaseTryAgain {
    return Intl.message(
      'Payment failed. Please try again.',
      name: 'paymentFailedPleaseTryAgain',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid brand name`
  String get pleaseEnterAValidBrandName {
    return Intl.message(
      'Please enter a valid brand name',
      name: 'pleaseEnterAValidBrandName',
      desc: '',
      args: [],
    );
  }

  /// `Enter a brand name`
  String get enterABrandName {
    return Intl.message(
      'Enter a brand name',
      name: 'enterABrandName',
      desc: '',
      args: [],
    );
  }

  /// `Add Category`
  String get addCategory {
    return Intl.message(
      'Add Category',
      name: 'addCategory',
      desc: '',
      args: [],
    );
  }

  /// `Enter category name`
  String get enterCategoryName {
    return Intl.message(
      'Enter category name',
      name: 'enterCategoryName',
      desc: '',
      args: [],
    );
  }

  /// `Select variations : `
  String get selectVariations {
    return Intl.message(
      'Select variations : ',
      name: 'selectVariations',
      desc: '',
      args: [],
    );
  }

  /// `Data saved successfully.`
  String get dataSavedSuccessfully {
    return Intl.message(
      'Data saved successfully.',
      name: 'dataSavedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Something is`
  String get somethingIs {
    return Intl.message(
      'Something is',
      name: 'somethingIs',
      desc: '',
      args: [],
    );
  }

  /// `Update your profile to connect your customer with better impression`
  String get updateYourProfile {
    return Intl.message(
      'Update your profile to connect your customer with better impression',
      name: 'updateYourProfile',
      desc: '',
      args: [],
    );
  }

  /// `Shop Opening Balance`
  String get shopOpeningBalance {
    return Intl.message(
      'Shop Opening Balance',
      name: 'shopOpeningBalance',
      desc: '',
      args: [],
    );
  }

  /// `Shop Remaining Balance`
  String get shopRemainingBalance {
    return Intl.message(
      'Shop Remaining Balance',
      name: 'shopRemainingBalance',
      desc: '',
      args: [],
    );
  }

  /// `Enter a valid Discount`
  String get enterAValidDiscount {
    return Intl.message(
      'Enter a valid Discount',
      name: 'enterAValidDiscount',
      desc: '',
      args: [],
    );
  }

  /// `Add product first`
  String get addProductFirst {
    return Intl.message(
      'Add product first',
      name: 'addProductFirst',
      desc: '',
      args: [],
    );
  }

  /// `Subtotal`
  String get subtotal {
    return Intl.message('Subtotal', name: 'subtotal', desc: '', args: []);
  }

  /// `Purchase Details`
  String get purchaseDetails {
    return Intl.message(
      'Purchase Details',
      name: 'purchaseDetails',
      desc: '',
      args: [],
    );
  }

  /// `Total:`
  String get totall {
    return Intl.message('Total:', name: 'totall', desc: '', args: []);
  }

  /// `Start Date`
  String get startDate {
    return Intl.message('Start Date', name: 'startDate', desc: '', args: []);
  }

  /// `Pick Start Date`
  String get pickStartDate {
    return Intl.message(
      'Pick Start Date',
      name: 'pickStartDate',
      desc: '',
      args: [],
    );
  }

  /// `End Date`
  String get endDate {
    return Intl.message('End Date', name: 'endDate', desc: '', args: []);
  }

  /// `Pick End Date`
  String get pickEndDate {
    return Intl.message(
      'Pick End Date',
      name: 'pickEndDate',
      desc: '',
      args: [],
    );
  }

  /// `Failed to get platform version.`
  String get failedToGetPlatformVersion {
    return Intl.message(
      'Failed to get platform version.',
      name: 'failedToGetPlatformVersion',
      desc: '',
      args: [],
    );
  }

  /// `Enter quantity`
  String get enterQuantity {
    return Intl.message(
      'Enter quantity',
      name: 'enterQuantity',
      desc: '',
      args: [],
    );
  }

  /// `Please add quantity`
  String get pleaseAddQuantity {
    return Intl.message(
      'Please add quantity',
      name: 'pleaseAddQuantity',
      desc: '',
      args: [],
    );
  }

  /// `Will be Added Soon`
  String get willBeAddedSoon {
    return Intl.message(
      'Will be Added Soon',
      name: 'willBeAddedSoon',
      desc: '',
      args: [],
    );
  }

  /// `Added To Cart`
  String get addedToCart {
    return Intl.message(
      'Added To Cart',
      name: 'addedToCart',
      desc: '',
      args: [],
    );
  }

  /// `Connect Your printer`
  String get connectYourPrinter {
    return Intl.message(
      'Connect Your printer',
      name: 'connectYourPrinter',
      desc: '',
      args: [],
    );
  }

  /// `Customer Pay`
  String get customerPay {
    return Intl.message(
      'Customer Pay',
      name: 'customerPay',
      desc: '',
      args: [],
    );
  }

  /// `Supplier Pay`
  String get supplerPay {
    return Intl.message('Supplier Pay', name: 'supplerPay', desc: '', args: []);
  }

  /// `Income Report`
  String get incomeReport {
    return Intl.message(
      'Income Report',
      name: 'incomeReport',
      desc: '',
      args: [],
    );
  }

  /// `Category`
  String get category {
    return Intl.message('Category', name: 'category', desc: '', args: []);
  }

  /// `Balance`
  String get balance {
    return Intl.message('Balance', name: 'balance', desc: '', args: []);
  }

  /// `items Sales`
  String get itemsSales {
    return Intl.message('items Sales', name: 'itemsSales', desc: '', args: []);
  }

  /// `Total Purchase`
  String get totalPurchase {
    return Intl.message(
      'Total Purchase',
      name: 'totalPurchase',
      desc: '',
      args: [],
    );
  }

  /// `Total Sales`
  String get totalSales {
    return Intl.message('Total Sales', name: 'totalSales', desc: '', args: []);
  }

  /// `Stock Report`
  String get stockReport {
    return Intl.message(
      'Stock Report',
      name: 'stockReport',
      desc: '',
      args: [],
    );
  }

  /// `Loss/Profit Report`
  String get lossProfitReport {
    return Intl.message(
      'Loss/Profit Report',
      name: 'lossProfitReport',
      desc: '',
      args: [],
    );
  }

  /// `Out Of Stock`
  String get outOfStock {
    return Intl.message('Out Of Stock', name: 'outOfStock', desc: '', args: []);
  }

  /// `VAT`
  String get vat {
    return Intl.message('VAT', name: 'vat', desc: '', args: []);
  }

  /// `Customer Phone Number`
  String get customerPhoneNumber {
    return Intl.message(
      'Customer Phone Number',
      name: 'customerPhoneNumber',
      desc: '',
      args: [],
    );
  }

  /// `Enter customer phone number`
  String get enterCustomerPhoneNumber {
    return Intl.message(
      'Enter customer phone number',
      name: 'enterCustomerPhoneNumber',
      desc: '',
      args: [],
    );
  }

  /// `Walk-in Customer`
  String get walkInCustomer {
    return Intl.message(
      'Walk-in Customer',
      name: 'walkInCustomer',
      desc: '',
      args: [],
    );
  }

  /// `Guest`
  String get guest {
    return Intl.message('Guest', name: 'guest', desc: '', args: []);
  }

  /// `Stock: `
  String get stocks {
    return Intl.message('Stock: ', name: 'stocks', desc: '', args: []);
  }

  /// `Lorem ipsum dolor sit amet, consectetur elit. Interdum cons.`
  String get loremIpsumDolorSitAmetConsecteturElitInterdumCons {
    return Intl.message(
      'Lorem ipsum dolor sit amet, consectetur elit. Interdum cons.',
      name: 'loremIpsumDolorSitAmetConsecteturElitInterdumCons',
      desc: '',
      args: [],
    );
  }

  /// `Do Not Disturb`
  String get doNotDisturb {
    return Intl.message(
      'Do Not Disturb',
      name: 'doNotDisturb',
      desc: '',
      args: [],
    );
  }

  /// `On`
  String get on {
    return Intl.message('On', name: 'on', desc: '', args: []);
  }

  /// `Off`
  String get off {
    return Intl.message('Off', name: 'off', desc: '', args: []);
  }

  /// `Unlimited Usages of Our Package👇`
  String get unlimitedUsagesOfOurPackage {
    return Intl.message(
      'Unlimited Usages of Our Package👇',
      name: 'unlimitedUsagesOfOurPackage',
      desc: '',
      args: [],
    );
  }

  /// `Lorem ipsum dolor sit amet, consectetur adipiscing elit. Natoque aliquet et, cur eget. Tellus sapien odio aliq.`
  String get loremIpsumDolor {
    return Intl.message(
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Natoque aliquet et, cur eget. Tellus sapien odio aliq.',
      name: 'loremIpsumDolor',
      desc: '',
      args: [],
    );
  }

  /// `Pay for Subscribe`
  String get payForSubscribe {
    return Intl.message(
      'Pay for Subscribe',
      name: 'payForSubscribe',
      desc: '',
      args: [],
    );
  }

  /// `Field`
  String get field {
    return Intl.message('Field', name: 'field', desc: '', args: []);
  }

  /// `successfully paid`
  String get successfullyPaid {
    return Intl.message(
      'successfully paid',
      name: 'successfullyPaid',
      desc: '',
      args: [],
    );
  }

  /// `Profile Edit`
  String get profileEdit {
    return Intl.message(
      'Profile Edit',
      name: 'profileEdit',
      desc: '',
      args: [],
    );
  }

  /// `Products`
  String get products {
    return Intl.message('Products', name: 'products', desc: '', args: []);
  }

  /// `Sales List`
  String get salesList {
    return Intl.message('Sales List', name: 'salesList', desc: '', args: []);
  }

  /// `User title can'n be empty`
  String get useTitleCanNotBeEmpty {
    return Intl.message(
      'User title can\'n be empty',
      name: 'useTitleCanNotBeEmpty',
      desc: '',
      args: [],
    );
  }

  /// `User Title`
  String get userTitle {
    return Intl.message('User Title', name: 'userTitle', desc: '', args: []);
  }

  /// `Enter User Title`
  String get enterUserTitle {
    return Intl.message(
      'Enter User Title',
      name: 'enterUserTitle',
      desc: '',
      args: [],
    );
  }

  /// `Create`
  String get create {
    return Intl.message('Create', name: 'create', desc: '', args: []);
  }

  /// `You Have To Give Permission`
  String get youHaveToGivePermission {
    return Intl.message(
      'You Have To Give Permission',
      name: 'youHaveToGivePermission',
      desc: '',
      args: [],
    );
  }

  /// `All`
  String get all {
    return Intl.message('All', name: 'all', desc: '', args: []);
  }

  /// `User Role Details`
  String get userRoleDetails {
    return Intl.message(
      'User Role Details',
      name: 'userRoleDetails',
      desc: '',
      args: [],
    );
  }

  /// `Do you want to delete the user?`
  String get doYouWantToDeleteTheUser {
    return Intl.message(
      'Do you want to delete the user?',
      name: 'doYouWantToDeleteTheUser',
      desc: '',
      args: [],
    );
  }

  /// `This Product Already added!`
  String get thisProductAlreadyAdded {
    return Intl.message(
      'This Product Already added!',
      name: 'thisProductAlreadyAdded',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid product Name`
  String get pleaseEnterAValidProductName {
    return Intl.message(
      'Please enter a valid product Name',
      name: 'pleaseEnterAValidProductName',
      desc: '',
      args: [],
    );
  }

  /// `Enter product Name`
  String get enterProductName {
    return Intl.message(
      'Enter product Name',
      name: 'enterProductName',
      desc: '',
      args: [],
    );
  }

  /// `Please select a category`
  String get pleaseSelectACategory {
    return Intl.message(
      'Please select a category',
      name: 'pleaseSelectACategory',
      desc: '',
      args: [],
    );
  }

  /// `Product Category`
  String get productCategory {
    return Intl.message(
      'Product Category',
      name: 'productCategory',
      desc: '',
      args: [],
    );
  }

  /// `Select Product Category`
  String get selectProductCategory {
    return Intl.message(
      'Select Product Category',
      name: 'selectProductCategory',
      desc: '',
      args: [],
    );
  }

  /// `Enter Size`
  String get enterSize {
    return Intl.message('Enter Size', name: 'enterSize', desc: '', args: []);
  }

  /// `Enter color`
  String get enterColor {
    return Intl.message('Enter color', name: 'enterColor', desc: '', args: []);
  }

  /// `Enter weight`
  String get enterWeight {
    return Intl.message(
      'Enter weight',
      name: 'enterWeight',
      desc: '',
      args: [],
    );
  }

  /// `Enter Capacity`
  String get enterCapacity {
    return Intl.message(
      'Enter Capacity',
      name: 'enterCapacity',
      desc: '',
      args: [],
    );
  }

  /// `Enter Type`
  String get enterType {
    return Intl.message('Enter Type', name: 'enterType', desc: '', args: []);
  }

  /// `Product Brand`
  String get productBrand {
    return Intl.message(
      'Product Brand',
      name: 'productBrand',
      desc: '',
      args: [],
    );
  }

  /// `Select a brand`
  String get selectABrand {
    return Intl.message(
      'Select a brand',
      name: 'selectABrand',
      desc: '',
      args: [],
    );
  }

  /// `product code is required`
  String get productCodeIsRequired {
    return Intl.message(
      'product code is required',
      name: 'productCodeIsRequired',
      desc: '',
      args: [],
    );
  }

  /// `Enter a valid stock`
  String get enterAValidStock {
    return Intl.message(
      'Enter a valid stock',
      name: 'enterAValidStock',
      desc: '',
      args: [],
    );
  }

  /// `Enter stock`
  String get enterStock {
    return Intl.message('Enter stock', name: 'enterStock', desc: '', args: []);
  }

  /// `Product Unit`
  String get productUnit {
    return Intl.message(
      'Product Unit',
      name: 'productUnit',
      desc: '',
      args: [],
    );
  }

  /// `Select Product Unit`
  String get selectProductUnit {
    return Intl.message(
      'Select Product Unit',
      name: 'selectProductUnit',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid purchase price`
  String get pleaseEnterAValidPurchasePrice {
    return Intl.message(
      'Please enter a valid purchase price',
      name: 'pleaseEnterAValidPurchasePrice',
      desc: '',
      args: [],
    );
  }

  /// `Enter Purchase price`
  String get enterPurchasePrice {
    return Intl.message(
      'Enter Purchase price',
      name: 'enterPurchasePrice',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid Sale price`
  String get pleaseEnterAValidSalePrice {
    return Intl.message(
      'Please enter a valid Sale price',
      name: 'pleaseEnterAValidSalePrice',
      desc: '',
      args: [],
    );
  }

  /// `Enter Salting price`
  String get enterSaltingPrice {
    return Intl.message(
      'Enter Salting price',
      name: 'enterSaltingPrice',
      desc: '',
      args: [],
    );
  }

  /// `Enter wholesale price`
  String get enterWholesalePrice {
    return Intl.message(
      'Enter wholesale price',
      name: 'enterWholesalePrice',
      desc: '',
      args: [],
    );
  }

  /// `Enter dealer price`
  String get enterDealerPrice {
    return Intl.message(
      'Enter dealer price',
      name: 'enterDealerPrice',
      desc: '',
      args: [],
    );
  }

  /// `Enter discount`
  String get enterDiscount {
    return Intl.message(
      'Enter discount',
      name: 'enterDiscount',
      desc: '',
      args: [],
    );
  }

  /// `Enter manufacturer name`
  String get enterManufacturerName {
    return Intl.message(
      'Enter manufacturer name',
      name: 'enterManufacturerName',
      desc: '',
      args: [],
    );
  }

  /// `Adding..`
  String get adding {
    return Intl.message('Adding..', name: 'adding', desc: '', args: []);
  }

  /// `Please enter a valid unit name`
  String get pleaseEnterAValidUnitName {
    return Intl.message(
      'Please enter a valid unit name',
      name: 'pleaseEnterAValidUnitName',
      desc: '',
      args: [],
    );
  }

  /// `Please enter unit name`
  String get pleaseEnterUnitName {
    return Intl.message(
      'Please enter unit name',
      name: 'pleaseEnterUnitName',
      desc: '',
      args: [],
    );
  }

  /// `Product Details`
  String get productDetails {
    return Intl.message(
      'Product Details',
      name: 'productDetails',
      desc: '',
      args: [],
    );
  }

  /// `Smart watch`
  String get smartWatch {
    return Intl.message('Smart watch', name: 'smartWatch', desc: '', args: []);
  }

  /// `Apple Watch`
  String get appleWatch {
    return Intl.message('Apple Watch', name: 'appleWatch', desc: '', args: []);
  }

  /// `Deleting....`
  String get deleting {
    return Intl.message('Deleting....', name: 'deleting', desc: '', args: []);
  }

  /// `Brand`
  String get brand {
    return Intl.message('Brand', name: 'brand', desc: '', args: []);
  }

  /// `Due collection`
  String get dueCollection {
    return Intl.message(
      'Due collection',
      name: 'dueCollection',
      desc: '',
      args: [],
    );
  }

  /// `No Transaction`
  String get noTransaction {
    return Intl.message(
      'No Transaction',
      name: 'noTransaction',
      desc: '',
      args: [],
    );
  }

  /// `Updating...`
  String get updating {
    return Intl.message('Updating...', name: 'updating', desc: '', args: []);
  }

  /// `Confirm SMS to`
  String get confirmSMSTo {
    return Intl.message(
      'Confirm SMS to',
      name: 'confirmSMSTo',
      desc: '',
      args: [],
    );
  }

  /// `An SMS will be sent to the following number: `
  String get anSMSWillBeSentToTheFollowingNumber {
    return Intl.message(
      'An SMS will be sent to the following number: ',
      name: 'anSMSWillBeSentToTheFollowingNumber',
      desc: '',
      args: [],
    );
  }

  /// `Package`
  String get package {
    return Intl.message('Package', name: 'package', desc: '', args: []);
  }

  /// `Permission not granted!`
  String get permissionNotGranted {
    return Intl.message(
      'Permission not granted!',
      name: 'permissionNotGranted',
      desc: '',
      args: [],
    );
  }

  /// `Collected By:`
  String get collectedBy {
    return Intl.message(
      'Collected By:',
      name: 'collectedBy',
      desc: '',
      args: [],
    );
  }

  /// `Phone:`
  String get phonee {
    return Intl.message('Phone:', name: 'phonee', desc: '', args: []);
  }

  /// `Purchase By:`
  String get purchaseBy {
    return Intl.message('Purchase By:', name: 'purchaseBy', desc: '', args: []);
  }

  /// `Sales By:`
  String get salesBy {
    return Intl.message('Sales By:', name: 'salesBy', desc: '', args: []);
  }

  /// `days`
  String get days {
    return Intl.message('days', name: 'days', desc: '', args: []);
  }

  /// `Details`
  String get details {
    return Intl.message('Details', name: 'details', desc: '', args: []);
  }

  /// `We sent an OTP in your phone number`
  String get weSentAnOTPInYourPhoneNumber {
    return Intl.message(
      'We sent an OTP in your phone number',
      name: 'weSentAnOTPInYourPhoneNumber',
      desc: '',
      args: [],
    );
  }

  /// `Please enter the OTP`
  String get pleaseEnterTheOTP {
    return Intl.message(
      'Please enter the OTP',
      name: 'pleaseEnterTheOTP',
      desc: '',
      args: [],
    );
  }

  /// `Enter a valid OTP`
  String get enterAValidOTP {
    return Intl.message(
      'Enter a valid OTP',
      name: 'enterAValidOTP',
      desc: '',
      args: [],
    );
  }

  /// `Verify`
  String get verify {
    return Intl.message('Verify', name: 'verify', desc: '', args: []);
  }

  /// `Resend OTP in `
  String get resendIn {
    return Intl.message('Resend OTP in ', name: 'resendIn', desc: '', args: []);
  }

  /// `Free Lifetime Update`
  String get freeLifetimeUpdate {
    return Intl.message(
      'Free Lifetime Update',
      name: 'freeLifetimeUpdate',
      desc: '',
      args: [],
    );
  }

  /// `Android & iOS App Support`
  String get android {
    return Intl.message(
      'Android & iOS App Support',
      name: 'android',
      desc: '',
      args: [],
    );
  }

  /// `Android & iOS App Support`
  String get premiumCustomerSupport {
    return Intl.message(
      'Android & iOS App Support',
      name: 'premiumCustomerSupport',
      desc: '',
      args: [],
    );
  }

  /// `Custom Invoice Branding`
  String get customInvoiceBranding {
    return Intl.message(
      'Custom Invoice Branding',
      name: 'customInvoiceBranding',
      desc: '',
      args: [],
    );
  }

  /// `Unlimited Usage`
  String get unlimitedUsage {
    return Intl.message(
      'Unlimited Usage',
      name: 'unlimitedUsage',
      desc: '',
      args: [],
    );
  }

  /// `Free Data Backup`
  String get freeDataBackup {
    return Intl.message(
      'Free Data Backup',
      name: 'freeDataBackup',
      desc: '',
      args: [],
    );
  }

  /// `Item`
  String get item {
    return Intl.message('Item', name: 'item', desc: '', args: []);
  }

  /// `SL`
  String get sl {
    return Intl.message('SL', name: 'sl', desc: '', args: []);
  }

  /// `Mobile`
  String get mobiles {
    return Intl.message('Mobile', name: 'mobiles', desc: '', args: []);
  }

  /// `Paid via`
  String get paidVia {
    return Intl.message('Paid via', name: 'paidVia', desc: '', args: []);
  }

  /// `Money Receipt`
  String get moneyReceipt {
    return Intl.message(
      'Money Receipt',
      name: 'moneyReceipt',
      desc: '',
      args: [],
    );
  }

  /// `Receipt`
  String get receipt {
    return Intl.message('Receipt', name: 'receipt', desc: '', args: []);
  }

  /// `Returned Item`
  String get returnedItem {
    return Intl.message(
      'Returned Item',
      name: 'returnedItem',
      desc: '',
      args: [],
    );
  }

  /// `Returned Date`
  String get returnedDate {
    return Intl.message(
      'Returned Date',
      name: 'returnedDate',
      desc: '',
      args: [],
    );
  }

  /// `Unit Price`
  String get unitPrice {
    return Intl.message('Unit Price', name: 'unitPrice', desc: '', args: []);
  }

  /// `Sales By`
  String get saleBy {
    return Intl.message('Sales By', name: 'saleBy', desc: '', args: []);
  }

  /// `Purchased By`
  String get purchasedBy {
    return Intl.message(
      'Purchased By',
      name: 'purchasedBy',
      desc: '',
      args: [],
    );
  }

  /// `Collected By`
  String get collectedBys {
    return Intl.message(
      'Collected By',
      name: 'collectedBys',
      desc: '',
      args: [],
    );
  }

  /// `Payable Amount`
  String get payableAmount {
    return Intl.message(
      'Payable Amount',
      name: 'payableAmount',
      desc: '',
      args: [],
    );
  }

  /// `Received Amount`
  String get receivedAmount {
    return Intl.message(
      'Received Amount',
      name: 'receivedAmount',
      desc: '',
      args: [],
    );
  }

  /// `Add Customer`
  String get addCustomers {
    return Intl.message(
      'Add Customer',
      name: 'addCustomers',
      desc: '',
      args: [],
    );
  }

  /// `No Due`
  String get noDue {
    return Intl.message('No Due', name: 'noDue', desc: '', args: []);
  }

  /// `Customer`
  String get customer {
    return Intl.message('Customer', name: 'customer', desc: '', args: []);
  }

  /// `Billing Address`
  String get billingAddress {
    return Intl.message(
      'Billing Address',
      name: 'billingAddress',
      desc: '',
      args: [],
    );
  }

  /// `Enter Address`
  String get enterAddress {
    return Intl.message(
      'Enter Address',
      name: 'enterAddress',
      desc: '',
      args: [],
    );
  }

  /// `City`
  String get city {
    return Intl.message('City', name: 'city', desc: '', args: []);
  }

  /// `City Name`
  String get cityName {
    return Intl.message('City Name', name: 'cityName', desc: '', args: []);
  }

  /// `State`
  String get state {
    return Intl.message('State', name: 'state', desc: '', args: []);
  }

  /// `State Name`
  String get stateName {
    return Intl.message('State Name', name: 'stateName', desc: '', args: []);
  }

  /// `Zip code`
  String get zip {
    return Intl.message('Zip code', name: 'zip', desc: '', args: []);
  }

  /// `Enter Zip code`
  String get zipCode {
    return Intl.message('Enter Zip code', name: 'zipCode', desc: '', args: []);
  }

  /// `Choose Country`
  String get chooseCountry {
    return Intl.message(
      'Choose Country',
      name: 'chooseCountry',
      desc: '',
      args: [],
    );
  }

  /// `Shipping Address`
  String get shippingAddress {
    return Intl.message(
      'Shipping Address',
      name: 'shippingAddress',
      desc: '',
      args: [],
    );
  }

  /// `You do not have permission to create Party.`
  String get partyCreateWarn {
    return Intl.message(
      'You do not have permission to create Party.',
      name: 'partyCreateWarn',
      desc: '',
      args: [],
    );
  }

  /// `Add Parties`
  String get addParty {
    return Intl.message('Add Parties', name: 'addParty', desc: '', args: []);
  }

  /// `Party Credit Limit`
  String get creditLimit {
    return Intl.message(
      'Party Credit Limit',
      name: 'creditLimit',
      desc: '',
      args: [],
    );
  }

  /// `Select One`
  String get selectOne {
    return Intl.message('Select One', name: 'selectOne', desc: '', args: []);
  }

  /// `Rounding (+/-)`
  String get roundings {
    return Intl.message(
      'Rounding (+/-)',
      name: 'roundings',
      desc: '',
      args: [],
    );
  }

  /// `Rounded Total`
  String get roundingTotal {
    return Intl.message(
      'Rounded Total',
      name: 'roundingTotal',
      desc: '',
      args: [],
    );
  }

  /// `Enter your opinion`
  String get opinion {
    return Intl.message(
      'Enter your opinion',
      name: 'opinion',
      desc: '',
      args: [],
    );
  }

  /// `Sales on due are not allowed for walk-in customers.`
  String get dueSaleWarn {
    return Intl.message(
      'Sales on due are not allowed for walk-in customers.',
      name: 'dueSaleWarn',
      desc: '',
      args: [],
    );
  }

  /// `Please select a payment type`
  String get paymentTypeHint {
    return Intl.message(
      'Please select a payment type',
      name: 'paymentTypeHint',
      desc: '',
      args: [],
    );
  }

  /// `You do not have permission to create sale.`
  String get createSaleWarn {
    return Intl.message(
      'You do not have permission to create sale.',
      name: 'createSaleWarn',
      desc: '',
      args: [],
    );
  }

  /// `You do not have permission to update sale.`
  String get updateSaleWarn {
    return Intl.message(
      'You do not have permission to update sale.',
      name: 'updateSaleWarn',
      desc: '',
      args: [],
    );
  }

  /// `Upload Image`
  String get uploadImage {
    return Intl.message(
      'Upload Image',
      name: 'uploadImage',
      desc: '',
      args: [],
    );
  }

  /// `Use gallery`
  String get useGallery {
    return Intl.message('Use gallery', name: 'useGallery', desc: '', args: []);
  }

  /// `Open Camera`
  String get openCamera {
    return Intl.message('Open Camera', name: 'openCamera', desc: '', args: []);
  }

  /// `Scan product QR code`
  String get scanCode {
    return Intl.message(
      'Scan product QR code',
      name: 'scanCode',
      desc: '',
      args: [],
    );
  }

  /// `Pos Sale`
  String get posSale {
    return Intl.message('Pos Sale', name: 'posSale', desc: '', args: []);
  }

  /// `Select Customer`
  String get selectCustomer {
    return Intl.message(
      'Select Customer',
      name: 'selectCustomer',
      desc: '',
      args: [],
    );
  }

  /// `Search...`
  String get searchWith {
    return Intl.message('Search...', name: 'searchWith', desc: '', args: []);
  }

  /// `Filter`
  String get filter {
    return Intl.message('Filter', name: 'filter', desc: '', args: []);
  }

  /// `Product Not found`
  String get productNotFound {
    return Intl.message(
      'Product Not found',
      name: 'productNotFound',
      desc: '',
      args: [],
    );
  }

  /// `No matched products found.`
  String get noMatched {
    return Intl.message(
      'No matched products found.',
      name: 'noMatched',
      desc: '',
      args: [],
    );
  }

  /// `You don't have inventory permission`
  String get inventoryPermission {
    return Intl.message(
      'You don\'t have inventory permission',
      name: 'inventoryPermission',
      desc: '',
      args: [],
    );
  }

  /// `No Parties Found`
  String get noParty {
    return Intl.message(
      'No Parties Found',
      name: 'noParty',
      desc: '',
      args: [],
    );
  }

  /// `You do not have permission to create purchases.`
  String get purchaseWarn {
    return Intl.message(
      'You do not have permission to create purchases.',
      name: 'purchaseWarn',
      desc: '',
      args: [],
    );
  }

  /// `You do not have permission to update purchases.`
  String get purchaseUpdateWarn {
    return Intl.message(
      'You do not have permission to update purchases.',
      name: 'purchaseUpdateWarn',
      desc: '',
      args: [],
    );
  }

  /// `Add Variant Details`
  String get addVariantDetails {
    return Intl.message(
      'Add Variant Details',
      name: 'addVariantDetails',
      desc: '',
      args: [],
    );
  }

  /// `Purchase Price Ex.`
  String get purchaseEx {
    return Intl.message(
      'Purchase Price Ex.',
      name: 'purchaseEx',
      desc: '',
      args: [],
    );
  }

  /// `Purchase Price Inc.`
  String get purchaseIn {
    return Intl.message(
      'Purchase Price Inc.',
      name: 'purchaseIn',
      desc: '',
      args: [],
    );
  }

  /// `Purchase price Ex. required`
  String get purchaseExReq {
    return Intl.message(
      'Purchase price Ex. required',
      name: 'purchaseExReq',
      desc: '',
      args: [],
    );
  }

  /// `Purchase price Inc. required`
  String get purchaseInReq {
    return Intl.message(
      'Purchase price Inc. required',
      name: 'purchaseInReq',
      desc: '',
      args: [],
    );
  }

  /// `Profit Margin`
  String get profitMargin {
    return Intl.message(
      'Profit Margin',
      name: 'profitMargin',
      desc: '',
      args: [],
    );
  }

  /// `Sales price required`
  String get saleReq {
    return Intl.message(
      'Sales price required',
      name: 'saleReq',
      desc: '',
      args: [],
    );
  }

  /// `Manufacture Date`
  String get manufactureDate {
    return Intl.message(
      'Manufacture Date',
      name: 'manufactureDate',
      desc: '',
      args: [],
    );
  }

  /// `Select Date`
  String get selectDate {
    return Intl.message('Select Date', name: 'selectDate', desc: '', args: []);
  }

  /// `Exp. Date`
  String get expDate {
    return Intl.message('Exp. Date', name: 'expDate', desc: '', args: []);
  }

  /// `Save Variant`
  String get saveVariant {
    return Intl.message(
      'Save Variant',
      name: 'saveVariant',
      desc: '',
      args: [],
    );
  }

  /// `Model`
  String get model {
    return Intl.message('Model', name: 'model', desc: '', args: []);
  }

  /// `Select Model`
  String get selectModel {
    return Intl.message(
      'Select Model',
      name: 'selectModel',
      desc: '',
      args: [],
    );
  }

  /// `Bulk Upload`
  String get bulk {
    return Intl.message('Bulk Upload', name: 'bulk', desc: '', args: []);
  }

  /// `Barcode Generator`
  String get barcodeGen {
    return Intl.message(
      'Barcode Generator',
      name: 'barcodeGen',
      desc: '',
      args: [],
    );
  }

  /// `Upload`
  String get upload {
    return Intl.message('Upload', name: 'upload', desc: '', args: []);
  }

  /// `SKU / Code`
  String get sku {
    return Intl.message('SKU / Code', name: 'sku', desc: '', args: []);
  }

  /// `Low Stock`
  String get lowStock {
    return Intl.message('Low Stock', name: 'lowStock', desc: '', args: []);
  }

  /// `Enter low stock`
  String get enLowStock {
    return Intl.message(
      'Enter low stock',
      name: 'enLowStock',
      desc: '',
      args: [],
    );
  }

  /// `Manufacture Date`
  String get manuDate {
    return Intl.message(
      'Manufacture Date',
      name: 'manuDate',
      desc: '',
      args: [],
    );
  }

  /// `Single`
  String get single {
    return Intl.message('Single', name: 'single', desc: '', args: []);
  }

  /// `Batch`
  String get batch {
    return Intl.message('Batch', name: 'batch', desc: '', args: []);
  }

  /// `Batch No.`
  String get batchNo {
    return Intl.message('Batch No.', name: 'batchNo', desc: '', args: []);
  }

  /// `Enter Batch No.`
  String get entBatchNo {
    return Intl.message(
      'Enter Batch No.',
      name: 'entBatchNo',
      desc: '',
      args: [],
    );
  }

  /// `Variant added successfully!`
  String get variantAdded {
    return Intl.message(
      'Variant added successfully!',
      name: 'variantAdded',
      desc: '',
      args: [],
    );
  }

  /// `Variant deleted successfully!`
  String get variantDelete {
    return Intl.message(
      'Variant deleted successfully!',
      name: 'variantDelete',
      desc: '',
      args: [],
    );
  }

  /// `Add Variant`
  String get addVariant {
    return Intl.message('Add Variant', name: 'addVariant', desc: '', args: []);
  }

  /// `Select Type`
  String get typeSelect {
    return Intl.message('Select Type', name: 'typeSelect', desc: '', args: []);
  }

  /// `Tax Type`
  String get taxType {
    return Intl.message('Tax Type', name: 'taxType', desc: '', args: []);
  }

  /// `Select Tax`
  String get selectTax {
    return Intl.message('Select Tax', name: 'selectTax', desc: '', args: []);
  }

  /// `You do not have permission to update Product.`
  String get updateProductWarn {
    return Intl.message(
      'You do not have permission to update Product.',
      name: 'updateProductWarn',
      desc: '',
      args: [],
    );
  }

  /// `You do not have permission to create Product.`
  String get addProductWarn {
    return Intl.message(
      'You do not have permission to create Product.',
      name: 'addProductWarn',
      desc: '',
      args: [],
    );
  }

  /// `Product Updated Successfully!`
  String get updateProductSuccess {
    return Intl.message(
      'Product Updated Successfully!',
      name: 'updateProductSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Product created successfully!`
  String get addProductSuccess {
    return Intl.message(
      'Product created successfully!',
      name: 'addProductSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Choose`
  String get choose {
    return Intl.message('Choose', name: 'choose', desc: '', args: []);
  }

  /// `View Details`
  String get view {
    return Intl.message('View Details', name: 'view', desc: '', args: []);
  }

  /// `Price Cannot be Empty`
  String get priceWarn {
    return Intl.message(
      'Price Cannot be Empty',
      name: 'priceWarn',
      desc: '',
      args: [],
    );
  }

  /// `Product Settings`
  String get productSetting {
    return Intl.message(
      'Product Settings',
      name: 'productSetting',
      desc: '',
      args: [],
    );
  }

  /// `Save Settings`
  String get saveSetting {
    return Intl.message(
      'Save Settings',
      name: 'saveSetting',
      desc: '',
      args: [],
    );
  }

  /// `Add Stock`
  String get addStock {
    return Intl.message('Add Stock', name: 'addStock', desc: '', args: []);
  }

  /// `Stock must be at least 1`
  String get stockWarn {
    return Intl.message(
      'Stock must be at least 1',
      name: 'stockWarn',
      desc: '',
      args: [],
    );
  }

  /// `Updated Successfully`
  String get updateSuccess {
    return Intl.message(
      'Updated Successfully',
      name: 'updateSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Failed to update stock`
  String get updateFailed {
    return Intl.message(
      'Failed to update stock',
      name: 'updateFailed',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete this Batch?`
  String get deleteBatchWarn {
    return Intl.message(
      'Are you sure you want to delete this Batch?',
      name: 'deleteBatchWarn',
      desc: '',
      args: [],
    );
  }

  /// `Low Stock Report`
  String get lowStockReport {
    return Intl.message(
      'Low Stock Report',
      name: 'lowStockReport',
      desc: '',
      args: [],
    );
  }

  /// `No data available for generate pdf`
  String get genPdfWarn {
    return Intl.message(
      'No data available for generate pdf',
      name: 'genPdfWarn',
      desc: '',
      args: [],
    );
  }

  /// `To Date cannot be before From Date.`
  String get dateFilterWarn {
    return Intl.message(
      'To Date cannot be before From Date.',
      name: 'dateFilterWarn',
      desc: '',
      args: [],
    );
  }

  /// `You do not have permission to create pdf.`
  String get createPdfWarn {
    return Intl.message(
      'You do not have permission to create pdf.',
      name: 'createPdfWarn',
      desc: '',
      args: [],
    );
  }

  /// `Expiration Status`
  String get expirationStatus {
    return Intl.message(
      'Expiration Status',
      name: 'expirationStatus',
      desc: '',
      args: [],
    );
  }

  /// `Select from date`
  String get selectFDate {
    return Intl.message(
      'Select from date',
      name: 'selectFDate',
      desc: '',
      args: [],
    );
  }

  /// `Select to date`
  String get selectToDate {
    return Intl.message(
      'Select to date',
      name: 'selectToDate',
      desc: '',
      args: [],
    );
  }

  /// `Clear`
  String get clear {
    return Intl.message('Clear', name: 'clear', desc: '', args: []);
  }

  /// `You do not have permission to view income report.`
  String get incomeReportPermission {
    return Intl.message(
      'You do not have permission to view income report.',
      name: 'incomeReportPermission',
      desc: '',
      args: [],
    );
  }

  /// `Delete Account`
  String get deleteAcc {
    return Intl.message(
      'Delete Account',
      name: 'deleteAcc',
      desc: '',
      args: [],
    );
  }

  /// `You do not have permission to delete party.`
  String get deletePartyWarn {
    return Intl.message(
      'You do not have permission to delete party.',
      name: 'deletePartyWarn',
      desc: '',
      args: [],
    );
  }

  /// `You do not have permission to update party.`
  String get updatePartyWarn {
    return Intl.message(
      'You do not have permission to update party.',
      name: 'updatePartyWarn',
      desc: '',
      args: [],
    );
  }

  /// `Phone number is not available.`
  String get phoneNotAvail {
    return Intl.message(
      'Phone number is not available.',
      name: 'phoneNotAvail',
      desc: '',
      args: [],
    );
  }

  /// `Could not launch the phone app.`
  String get notLaunch {
    return Intl.message(
      'Could not launch the phone app.',
      name: 'notLaunch',
      desc: '',
      args: [],
    );
  }

  /// `Quick Overview`
  String get quickOver {
    return Intl.message(
      'Quick Overview',
      name: 'quickOver',
      desc: '',
      args: [],
    );
  }

  /// `Transaction Overview`
  String get tranSacOver {
    return Intl.message(
      'Transaction Overview',
      name: 'tranSacOver',
      desc: '',
      args: [],
    );
  }

  /// `Profit & Loss`
  String get profitLoss {
    return Intl.message(
      'Profit & Loss',
      name: 'profitLoss',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'af'),
      Locale.fromSubtags(languageCode: 'am'),
      Locale.fromSubtags(languageCode: 'ar'),
      Locale.fromSubtags(languageCode: 'as'),
      Locale.fromSubtags(languageCode: 'az'),
      Locale.fromSubtags(languageCode: 'be'),
      Locale.fromSubtags(languageCode: 'bg'),
      Locale.fromSubtags(languageCode: 'bn'),
      Locale.fromSubtags(languageCode: 'bs'),
      Locale.fromSubtags(languageCode: 'ca'),
      Locale.fromSubtags(languageCode: 'cs'),
      Locale.fromSubtags(languageCode: 'cy'),
      Locale.fromSubtags(languageCode: 'da'),
      Locale.fromSubtags(languageCode: 'de'),
      Locale.fromSubtags(languageCode: 'el'),
      Locale.fromSubtags(languageCode: 'es'),
      Locale.fromSubtags(languageCode: 'et'),
      Locale.fromSubtags(languageCode: 'eu'),
      Locale.fromSubtags(languageCode: 'fa'),
      Locale.fromSubtags(languageCode: 'fi'),
      Locale.fromSubtags(languageCode: 'fil'),
      Locale.fromSubtags(languageCode: 'fr'),
      Locale.fromSubtags(languageCode: 'gl'),
      Locale.fromSubtags(languageCode: 'gsw'),
      Locale.fromSubtags(languageCode: 'gu'),
      Locale.fromSubtags(languageCode: 'ha'),
      Locale.fromSubtags(languageCode: 'he'),
      Locale.fromSubtags(languageCode: 'hi'),
      Locale.fromSubtags(languageCode: 'hr'),
      Locale.fromSubtags(languageCode: 'hu'),
      Locale.fromSubtags(languageCode: 'hy'),
      Locale.fromSubtags(languageCode: 'id'),
      Locale.fromSubtags(languageCode: 'is'),
      Locale.fromSubtags(languageCode: 'it'),
      Locale.fromSubtags(languageCode: 'ja'),
      Locale.fromSubtags(languageCode: 'ka'),
      Locale.fromSubtags(languageCode: 'kk'),
      Locale.fromSubtags(languageCode: 'km'),
      Locale.fromSubtags(languageCode: 'kn'),
      Locale.fromSubtags(languageCode: 'ko'),
      Locale.fromSubtags(languageCode: 'ky'),
      Locale.fromSubtags(languageCode: 'lo'),
      Locale.fromSubtags(languageCode: 'lt'),
      Locale.fromSubtags(languageCode: 'lv'),
      Locale.fromSubtags(languageCode: 'mk'),
      Locale.fromSubtags(languageCode: 'ml'),
      Locale.fromSubtags(languageCode: 'mn'),
      Locale.fromSubtags(languageCode: 'mr'),
      Locale.fromSubtags(languageCode: 'ms'),
      Locale.fromSubtags(languageCode: 'my'),
      Locale.fromSubtags(languageCode: 'nb'),
      Locale.fromSubtags(languageCode: 'ne'),
      Locale.fromSubtags(languageCode: 'nl'),
      Locale.fromSubtags(languageCode: 'no'),
      Locale.fromSubtags(languageCode: 'or'),
      Locale.fromSubtags(languageCode: 'pa'),
      Locale.fromSubtags(languageCode: 'pl'),
      Locale.fromSubtags(languageCode: 'ps'),
      Locale.fromSubtags(languageCode: 'pt'),
      Locale.fromSubtags(languageCode: 'ro'),
      Locale.fromSubtags(languageCode: 'ru'),
      Locale.fromSubtags(languageCode: 'si'),
      Locale.fromSubtags(languageCode: 'sk'),
      Locale.fromSubtags(languageCode: 'sl'),
      Locale.fromSubtags(languageCode: 'sq'),
      Locale.fromSubtags(languageCode: 'sr'),
      Locale.fromSubtags(languageCode: 'sv'),
      Locale.fromSubtags(languageCode: 'sw'),
      Locale.fromSubtags(languageCode: 'ta'),
      Locale.fromSubtags(languageCode: 'te'),
      Locale.fromSubtags(languageCode: 'th'),
      Locale.fromSubtags(languageCode: 'tl'),
      Locale.fromSubtags(languageCode: 'tr'),
      Locale.fromSubtags(languageCode: 'tt'),
      Locale.fromSubtags(languageCode: 'uk'),
      Locale.fromSubtags(languageCode: 'ur'),
      Locale.fromSubtags(languageCode: 'uz'),
      Locale.fromSubtags(languageCode: 'vi'),
      Locale.fromSubtags(languageCode: 'zh'),
      Locale.fromSubtags(languageCode: 'zu'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
