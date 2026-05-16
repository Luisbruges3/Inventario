import 'package:flutter/material.dart';

class Contenedor extends StatelessWidget {
  const Contenedor({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 200, 
        backgroundColor: Colors.white,
        title: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Hi Laura!", style: TextStyle(fontSize: 30,color:Colors.brown, fontWeight: FontWeight.w600),),
              Text("Let's track your", style: TextStyle(fontSize: 20),),
              Text("pets progress", style: TextStyle(fontSize: 20),),
            ],
          ),
              Spacer(),
              Image.network('https://cdn-icons-png.flaticon.com/512/5904/5904059.png', width: 70, height: 100,),
          ],
        ),
      ),



      body: Column(
      children: [
        SizedBox(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.3,
          padding: EdgeInsets.only(left: 20, top: 30),
          //color: Colors.red,
          decoration: BoxDecoration(
            color:Color.fromARGB(255, 212, 221, 225),
            borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:[
                Text("Zoe's Activity", style: TextStyle(fontSize: 35, color: Colors.white),),
                SizedBox(height: 20,),

                SizedBox(height: 170,
                child: ListView(scrollDirection: Axis.horizontal,
                children: [
                  tarjeta("Today Walks", "3","Walks", const Color.fromARGB(255, 199, 49, 226), const Color.fromARGB(255, 108, 24, 122) ,context), SizedBox(width: 20,),
                  tarjeta("Minutes Played", "45", "Minutes", Colors.green, const Color.fromARGB(255, 19, 119, 22) ,context), SizedBox(width: 20,),
                  tarjeta("Food Servings", "5", "Servings", const Color.fromARGB(255, 255, 230, 0), const Color.fromARGB(255, 255, 155, 5) ,context), SizedBox(width: 20,),
                ],),)

              ],
            ),
          ),
      ),
        

      
        Expanded(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            padding: EdgeInsets.all(20),
            //color: Colors.red,
            decoration: BoxDecoration(
              color:Color.fromARGB(255, 212, 221, 225),
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
            ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:[
                  Text("Zoe's Health", style: TextStyle(fontSize: 35, color: Colors.white),),
                  SizedBox(height: 20,),

                  Expanded(child: ListView(scrollDirection: Axis.vertical,
                  children: [
                    monitoreo("Medication", "Given: 7:30AM","Carprofen, 50 mg", Colors.white, Colors.black, 'https://cdn-icons-png.flaticon.com/512/918/918330.png', 'Completed', context), SizedBox(height: 20,),
                    monitoreo("Weight", "Current: 25.5 kg", "Last Week: 25.0 kg", const Color.fromARGB(255, 255, 230, 0), Colors.black, 'https://cdn-icons-png.freepik.com/512/7002/7002824.png', '+ 0.5 kg', context), SizedBox(height: 20,),
                    monitoreo("Heart Rate", "Current: 55 BPM", "Last Week Avg: 68 BPM", const Color.fromARGB(255, 235, 134, 33), Colors.black, 'https://images.vexels.com/media/users/3/135453/isolated/preview/a0b38c31d0a9712a2c4d2819f833d894-icono-de-gotas-de-sangre.png', 'Consistent', context),
                  ],),
                  )
                ],
              ),
            ),
          )
        
        ],
      ),

      

    );
  }

  Widget tarjeta(String titulo, String contenido, String subtitulo, Color color, Color colorTexto, BuildContext context){
    return Container(
      width: 150,
      height: 200,
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Column(
        //mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(titulo, style: TextStyle(color: colorTexto, fontSize: 22.5,), textAlign: TextAlign.center,),
          Text(contenido, style: TextStyle(color: colorTexto, fontSize: 38, fontWeight: FontWeight.w700),textAlign: TextAlign.center,),
          Spacer(),
          Text(subtitulo, style: TextStyle(color: colorTexto, fontSize: 15),textAlign: TextAlign.center,)
        ]
      )
    );
  }

  Widget monitoreo(String titulo, String contenido, String subtitulo, Color color, Color colorTexto, String imagen,String textoFinal,BuildContext context){
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 100,
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Row(
        //mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(imagen, width: 45, height: 100,),
          SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children:[
                Text(titulo, style: TextStyle(color: colorTexto, fontSize: 15,),),
                Text(contenido, style: TextStyle(color: colorTexto, fontSize: 19, fontWeight: FontWeight.w700),),
                Spacer(),
                Text(subtitulo, style: TextStyle(color: colorTexto, fontSize: 15),)
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children:[
              Text(textoFinal, style:TextStyle(color: Colors.green, fontSize: 18))
            ],),
        ]
      )
    );
  
  }
}