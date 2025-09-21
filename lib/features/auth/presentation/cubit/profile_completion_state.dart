import 'package:equatable/equatable.dart';
import '../../domain/entities/brand.dart';

// Profile completion states
abstract class ProfileCompletionState extends Equatable {
  const ProfileCompletionState();

  @override
  List<Object?> get props => [];
}

class ProfileCompletionInitial extends ProfileCompletionState {}

class ProfileCompletionLoading extends ProfileCompletionState {}

class BrandsLoading extends ProfileCompletionState {}

class BrandsLoaded extends ProfileCompletionState {
  final BrandResponse brands;

  const BrandsLoaded(this.brands);

  @override
  List<Object?> get props => [brands];
}

class BrandsError extends ProfileCompletionState {
  final String message;

  const BrandsError(this.message);

  @override
  List<Object?> get props => [message];
}

class ProfileCompletionSuccess extends ProfileCompletionState {}

class ProfileCompletionError extends ProfileCompletionState {
  final String message;

  const ProfileCompletionError(this.message);

  @override
  List<Object?> get props => [message];
}

// Data models for form state
class ProfileCompletionData {
  // Step 1 - Bowling Style & Membership
  final String bowlingStyle;
  final String average;
  final String division;
  final bool isPBACardHolder;
  final String? pbaNumber;
  final bool isUSBCMember;
  final String? usbcNumber;

  // Step 2 - Location Information
  final String city;
  final String state;
  final String zipCode;

  // Step 3 - Brand Selection
  final List<int> selectedBrandIds;

  const ProfileCompletionData({
    this.bowlingStyle = 'One Handed',
    this.average = '',
    this.division = '',
    this.isPBACardHolder = false,
    this.pbaNumber,
    this.isUSBCMember = false,
    this.usbcNumber,
    this.city = '',
    this.state = '',
    this.zipCode = '',
    this.selectedBrandIds = const [],
  });

  ProfileCompletionData copyWith({
    String? bowlingStyle,
    String? average,
    String? division,
    bool? isPBACardHolder,
    String? pbaNumber,
    bool? isUSBCMember,
    String? usbcNumber,
    String? city,
    String? state,
    String? zipCode,
    List<int>? selectedBrandIds,
  }) {
    return ProfileCompletionData(
      bowlingStyle: bowlingStyle ?? this.bowlingStyle,
      average: average ?? this.average,
      division: division ?? this.division,
      isPBACardHolder: isPBACardHolder ?? this.isPBACardHolder,
      pbaNumber: pbaNumber ?? this.pbaNumber,
      isUSBCMember: isUSBCMember ?? this.isUSBCMember,
      usbcNumber: usbcNumber ?? this.usbcNumber,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      selectedBrandIds: selectedBrandIds ?? this.selectedBrandIds,
    );
  }

  bool get isStep1Valid {
    return average.isNotEmpty &&
           division.isNotEmpty &&
           (!isPBACardHolder || (pbaNumber?.isNotEmpty ?? false)) &&
           (!isUSBCMember || (usbcNumber?.isNotEmpty ?? false));
  }

  bool get isStep2Valid {
    return city.isNotEmpty &&
           state.isNotEmpty &&
           zipCode.isNotEmpty;
  }

  bool get isStep3Valid {
    return selectedBrandIds.isNotEmpty;
  }
}