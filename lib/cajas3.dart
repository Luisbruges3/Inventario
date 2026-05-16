import 'package:flutter/material.dart';
import 'CustomTextField.dart';

class Cajas3 extends StatefulWidget {
  const Cajas3({super.key});

    @override
    State <Cajas3>createState() => _CajasState();
}

class _CajasState extends State<Cajas3> {
  TextEditingController cntTotalCuenta = TextEditingController();
  double? Propina;
  double? TotalPagar;
  String porcentajeProp = '10';
  bool mostrar = false;

  void calcularTotal(){
    int totalC = int.parse(cntTotalCuenta.text);
    setState((){
      mostrar = true;
      Propina=(totalC * (double.parse(porcentajeProp)/100)).toDouble();
      TotalPagar=(totalC+(Propina ?? 0)).toDouble();}
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:Text('Ej: Columnas'),),
      body: Column(children: [
        
          CustomTextField(placeholder:"Digite el total de la cuenta",
                          cnt: cntTotalCuenta,
                          typeKeyboard: TextInputType.number,),
          SizedBox(height:10),
          
          Text('Que porcentaje de propina desea dejar?', style: TextStyle(fontSize: 18),),

          SizedBox(
            width: double.infinity,
            child:
            Row(
              children:[
                Expanded(
                  child:
                    RadioListTile(title: Text('10'),
                    value: '10',
                    groupValue:porcentajeProp,
                    onChanged:(value){
                      setState((){
                        porcentajeProp=value.toString();
                      });}
                    ),
                  ),

                Expanded(
                  child:
                    RadioListTile(title: Text('15'),
                    value: '15',
                    groupValue:porcentajeProp,
                    onChanged:(value){
                        setState((){
                        porcentajeProp=value.toString();
                      });
                    }
                  ),
                ),

                Expanded(
                  child:
                    RadioListTile(title: Text('20'),
                    value: '20',
                    groupValue:porcentajeProp,
                    onChanged:(value){
                      setState((){
                        porcentajeProp=value.toString();
                      });}
                    ),
                  ),

                Expanded(
                  child:
                    RadioListTile(title: Text('25'),
                    value: '25',
                    groupValue:porcentajeProp,
                    onChanged:(value){
                        setState((){
                        porcentajeProp=value.toString();
                      });
                    }
                  ),
                ),
              ]
            ),
          ),

          
          ElevatedButton(
              onPressed:(){calcularTotal();
            }, child:Text("Calcular")
          ),

          SizedBox(height:10),

          if(mostrar)
          Text("Dejaste $Propina pesos de propina, ahora el valor total a pagar es de $TotalPagar pesos"),
        ]

      )
    );
  }

}

