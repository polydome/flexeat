import 'dart:async';

mixin LiveRepository<E> {
  final StreamController<E> _dataEventController = StreamController(sync: true);

  Stream<E> get dataEvents => _dataEventController.stream;

  void emit(E dataEvent) {
    _dataEventController.add(dataEvent);
  }
}
