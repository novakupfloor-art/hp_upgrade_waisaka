import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

class MortgageCalculator {
  final double propertyPrice;
  final double downPaymentPercent;
  final double annualInterestRate;
  final int loanTenureYears;
  final double fixedRatePeriodYears;

  MortgageCalculator({
    required this.propertyPrice,
    this.downPaymentPercent = 20.0,
    this.annualInterestRate = 11.5,
    this.loanTenureYears = 20,
    this.fixedRatePeriodYears = 5,
  });

  /// Calculate down payment amount
  double get downPayment => propertyPrice * (downPaymentPercent / 100);

  /// Calculate loan amount
  double get loanAmount => propertyPrice - downPayment;

  /// Monthly interest rate (as decimal)
  double get monthlyInterestRate => annualInterestRate / 100 / 12;

  /// Total number of payments
  int get totalPayments => loanTenureYears * 12;

  /// Fixed rate period payments
  int get fixedRatePayments => (fixedRatePeriodYears * 12).round();

  /// Floating rate period payments
  int get floatingRatePayments => totalPayments - fixedRatePayments;

  /// Calculate monthly installment using standard formula
  double _calculateMonthlyPayment(double principal, double rate, int periods) {
    if (rate == 0) return principal / periods;

    return principal *
        (rate * math.pow(1 + rate, periods)) /
        (math.pow(1 + rate, periods) - 1);
  }

  /// Calculate fixed rate period payment
  double get fixedRatePayment =>
      _calculateMonthlyPayment(loanAmount, monthlyInterestRate, totalPayments);

  /// Calculate floating rate period payment (assuming 2% increase)
  double get floatingRatePayment {
    final increasedRate = (annualInterestRate + 2.0) / 100 / 12;
    final remainingPrincipal = _calculateRemainingPrincipal(fixedRatePayments);
    return _calculateMonthlyPayment(
      remainingPrincipal,
      increasedRate,
      floatingRatePayments,
    );
  }

  /// Calculate remaining principal after certain number of payments
  double _calculateRemainingPrincipal(int paymentsMade) {
    if (monthlyInterestRate == 0) {
      return loanAmount - (fixedRatePayment * paymentsMade);
    }

    return loanAmount *
        (math.pow(1 + monthlyInterestRate, paymentsMade) -
            (fixedRatePayment / monthlyInterestRate) *
                (math.pow(1 + monthlyInterestRate, paymentsMade) - 1)) /
        math.pow(1 + monthlyInterestRate, paymentsMade);
  }

  /// Calculate total payment over entire loan period
  double get totalPayment {
    final fixedPeriodTotal = fixedRatePayment * fixedRatePayments;
    final floatingPeriodTotal = floatingRatePayment * floatingRatePayments;
    return fixedPeriodTotal + floatingPeriodTotal;
  }

  /// Calculate total interest paid
  double get totalInterest => totalPayment - loanAmount;

  /// Generate detailed payment schedule
  List<PaymentSchedule> generatePaymentSchedule() {
    final schedule = <PaymentSchedule>[];
    double remainingPrincipal = loanAmount;

    for (int month = 1; month <= totalPayments; month++) {
      final isFixedRate = month <= fixedRatePayments;
      final monthlyPayment = isFixedRate
          ? fixedRatePayment
          : floatingRatePayment;
      final interestPayment = remainingPrincipal * monthlyInterestRate;
      final principalPayment = monthlyPayment - interestPayment;

      remainingPrincipal -= principalPayment;

      schedule.add(
        PaymentSchedule(
          month: month,
          payment: monthlyPayment,
          principal: principalPayment,
          interest: interestPayment,
          balance: remainingPrincipal > 0 ? remainingPrincipal : 0,
          isFixedRate: isFixedRate,
        ),
      );
    }

    return schedule;
  }

  /// Get affordability analysis
  AffordabilityAnalysis getAffordabilityAnalysis(double monthlyIncome) {
    final monthlyPayment = fixedRatePayment;
    final debtToIncomeRatio = (monthlyPayment / monthlyIncome) * 100;

    // Bank requirements in Indonesia
    final maxDebtToIncomeRatio = 35.0; // 35% max
    final minimumIncome = monthlyPayment * (100 / maxDebtToIncomeRatio);

    return AffordabilityAnalysis(
      monthlyIncome: monthlyIncome,
      monthlyPayment: monthlyPayment,
      debtToIncomeRatio: debtToIncomeRatio,
      maxRecommendedRatio: maxDebtToIncomeRatio,
      minimumRequiredIncome: minimumIncome,
      isAffordable: debtToIncomeRatio <= maxDebtToIncomeRatio,
    );
  }
}

class PaymentSchedule {
  final int month;
  final double payment;
  final double principal;
  final double interest;
  final double balance;
  final bool isFixedRate;

  PaymentSchedule({
    required this.month,
    required this.payment,
    required this.principal,
    required this.interest,
    required this.balance,
    required this.isFixedRate,
  });

  String get formattedPayment => NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  ).format(payment);

  String get formattedPrincipal => NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  ).format(principal);

  String get formattedInterest => NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  ).format(interest);

  String get formattedBalance => NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  ).format(balance);

  String get periodType => isFixedRate ? 'Fixed Rate' : 'Floating Rate';
}

class AffordabilityAnalysis {
  final double monthlyIncome;
  final double monthlyPayment;
  final double debtToIncomeRatio;
  final double maxRecommendedRatio;
  final double minimumRequiredIncome;
  final bool isAffordable;

  AffordabilityAnalysis({
    required this.monthlyIncome,
    required this.monthlyPayment,
    required this.debtToIncomeRatio,
    required this.maxRecommendedRatio,
    required this.minimumRequiredIncome,
    required this.isAffordable,
  });

  String get formattedMonthlyIncome => NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  ).format(monthlyIncome);

  String get formattedMonthlyPayment => NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  ).format(monthlyPayment);

  String get formattedMinimumIncome => NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  ).format(minimumRequiredIncome);

  String get ratioStatus {
    if (debtToIncomeRatio <= 25) return 'Sangat Aman';
    if (debtToIncomeRatio <= 30) return 'Aman';
    if (debtToIncomeRatio <= 35) return 'Cukup Aman';
    return 'Berisiko';
  }

  Color get ratioColor {
    if (debtToIncomeRatio <= 25) return Colors.green;
    if (debtToIncomeRatio <= 30) return Colors.blue;
    if (debtToIncomeRatio <= 35) return Colors.orange;
    return Colors.red;
  }
}
