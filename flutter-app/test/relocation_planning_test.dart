import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:aasha/features/official/presentation/relocation_planning_screen.dart';

void main(){
  testWidgets('Only simple habitation fields and location controls are shown',(tester)async{
    final client=MockClient((r)async=>http.Response(jsonEncode({'habitations':[],'result':{'zones':[],'priorities':[],'camps':[],'unmappedAlerts':0},'generated':false,'reviewed':false}),200));
    await tester.pumpWidget(MaterialApp(home:RelocationPlanningScreen(client:client)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add Habitation'));await tester.pumpAndSettle();
    expect(find.text('Habitation Name'),findsOneWidget);
    expect(find.text('Total Population'),findsOneWidget);
    expect(find.text('Pick on Map'),findsOneWidget);
    expect(find.text('Use Current Location'),findsOneWidget);
    expect(find.byType(TextField),findsNWidgets(2));
    await tester.tap(find.text('Save habitation'));await tester.pumpAndSettle();
    expect(find.text('Complete the name, location and valid counts.'),findsOneWidget);
    await tester.tap(find.text('Cancel'));await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds:300));
    expect(tester.takeException(),isNull);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('Network failure never shows current priorities',(tester)async{
    final client=MockClient((r)async=>http.Response('{"error":"Officer access required"}',403));
    await tester.pumpWidget(MaterialApp(home:RelocationPlanningScreen(client:client)));await tester.pumpAndSettle();
    expect(find.textContaining('Officer access required'),findsOneWidget);
    expect(find.text('Add Habitation'),findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}
