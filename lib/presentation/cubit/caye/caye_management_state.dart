class CayeManagementState {
  final bool isConnected;
  const CayeManagementState({this.isConnected = false});
  CayeManagementState copyWith({bool? isConnected}) =>
      CayeManagementState(isConnected: isConnected ?? this.isConnected);
}
