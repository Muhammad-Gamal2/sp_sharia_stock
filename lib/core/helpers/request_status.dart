enum RequestStatus { initial, inProgress, success, failure }

extension RequestStatusX on RequestStatus {
  bool get isInitial => this == RequestStatus.initial;

  bool get isInProgress => this == RequestStatus.inProgress;

  bool get isSuccess => this == RequestStatus.success;

  bool get isFailure => this == RequestStatus.failure;
}
