import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/organization_entity.dart';
import '../../domain/repositories/organization_repository.dart';

abstract class OrganizationState extends Equatable {
  const OrganizationState();

  @override
  List<Object?> get props => [];
}

class OrganizationInitial extends OrganizationState {}

class OrganizationLoading extends OrganizationState {}

class OrganizationLoaded extends OrganizationState {
  final List<OrganizationEntity> organizations;
  final String? searchQuery;

  const OrganizationLoaded({required this.organizations, this.searchQuery});

  @override
  List<Object?> get props => [organizations, searchQuery];
}

class OrganizationEmpty extends OrganizationState {}

class OrganizationError extends OrganizationState {
  final String message;

  const OrganizationError({required this.message});

  @override
  List<Object?> get props => [message];
}

class OrganizationCubit extends Cubit<OrganizationState> {
  final OrganizationRepository repository;

  OrganizationCubit({required this.repository}) : super(OrganizationInitial());

  Future<void> loadOrganizations({String? searchQuery}) async {
    if (isClosed) return;
    emit(OrganizationLoading());
    try {
      final orgs = await repository.getActiveOrganizations(searchQuery: searchQuery);
      if (isClosed) return;
      if (orgs.isEmpty) {
        emit(OrganizationEmpty());
      } else {
        emit(OrganizationLoaded(organizations: orgs, searchQuery: searchQuery));
      }
    } catch (e) {
      if (isClosed) return;
      emit(OrganizationError(message: e.toString()));
    }
  }
}
