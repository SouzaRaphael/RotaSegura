import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rota_segura/models/place.dart';
import 'package:rota_segura/widgets/routes/trip_fields.dart';

class _Host extends StatefulWidget {
  const _Host();

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  Place? origin = const Place(name: 'Avenida Paulista', address: '', latitude: -23.56, longitude: -46.65);
  Place? destination = const Place(name: 'Parque Ibirapuera', address: '', latitude: -23.58, longitude: -46.66);

  bool get _empty => origin == null && destination == null;

  @override
  Widget build(BuildContext context) => TripFields(
    origin: origin,
    destination: destination,
    onPickOrigin: () {},
    onPickDestination: () {},
    onSwap: _empty
        ? null
        : () => setState(() {
            final previous = origin;
            origin = destination;
            destination = previous;
          }),
    onClear: _empty ? null : () => setState(() => origin = destination = null),
  );
}

void main() {
  testWidgets('"Limpar campos" esvazia origem e destino e depois fica desabilitado', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: _Host())));
    expect(find.text('Avenida Paulista'), findsOneWidget);

    await tester.tap(find.text('Limpar campos'));
    await tester.pump();

    expect(find.text('Avenida Paulista'), findsNothing);
    expect(find.text('Parque Ibirapuera'), findsNothing);
    expect(find.text('De onde você sai?'), findsOneWidget);
    expect(find.text('Para onde você vai?'), findsOneWidget);

    final clear = tester.widget<TextButton>(find.ancestor(of: find.text('Limpar campos'), matching: find.byType(TextButton)));
    expect(clear.onPressed, isNull);
  });
}
