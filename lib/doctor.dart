import 'package:flutter/material.dart';


class Doctor extends StatelessWidget {
  const Doctor({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 150, 
        backgroundColor: Colors.white,
        title: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Hola Dr. Sánchez", style: TextStyle(fontSize: 35,color:Colors.brown, fontWeight: FontWeight.w600),),
              Text("Welcome to yout pet clinic", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),),
            ],
          ),
              Spacer(),
              Image.network('https://cdn-icons-png.flaticon.com/512/1869/1869414.png', width: 80, height: 100,),
          ],
        ),
      ),

      body: Column(
      children: [
        SizedBox(
                height: MediaQuery.of(context).size.height*0.355,
                child: SingleChildScrollView(scrollDirection: Axis.horizontal,
                child:Row(
                  children:[
                    
                    Container(
                      width: MediaQuery.of(context).size.width*0.9,
                      height: MediaQuery.of(context).size.height*0.355,
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color:Color.fromARGB(255, 212, 221, 225),
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(20)),
                      ),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children:[
                            Text("Today's Summary", style: TextStyle(fontSize: 30, color: Colors.black, fontFamily: 'momoSignature'),),
                            SizedBox(height: 10,),

                            ListView(
                              shrinkWrap:true,physics: NeverScrollableScrollPhysics(), //Estaba teniendo overflow en las columnas de la derecha y me salia una barra de scroll
                              children: [
                                monitoreo("Appointments", Colors.lightBlue, Colors.white, 'https://cdn-icons-png.flaticon.com/512/942/942759.png', '5', context), SizedBox(height: 10,),
                                monitoreo("Hospitalized Pets",  Colors.lightGreen, Colors.white, 'https://cdn-icons-png.freepik.com/512/5900/5900187.png', '3', context), SizedBox(height: 10,),
                                monitoreo("Pendind Tasks", const Color.fromARGB(255, 164, 33, 235), Colors.white, 'https://cdn-icons-png.flaticon.com/512/2310/2310700.png', '7', context),
                                    ],
                                  ),
                            ],
                          ),
                        ),
                      
                      Container(
                        width: MediaQuery.of(context).size.width*0.9, 
                        padding: EdgeInsets.only(top:73, right:20),
                        decoration: BoxDecoration(
                        color:Color.fromARGB(255, 212, 221, 225),
                        borderRadius: BorderRadius.only( topRight: Radius.circular(20)),
                        
                      ),
                        child: ListView(
                          
                          children: [
                            
                             monitoreo( "Check-ups", const Color.fromARGB(255, 255, 174, 60), Colors.white, 'https://cdn-icons-png.flaticon.com/512/2764/2764533.png', '2', context), SizedBox(height: 10,),
                              monitoreo("Notes", const Color.fromARGB(255, 177, 60, 255), Colors.white, 'https://cdn-icons-png.flaticon.com/512/768/768818.png', '15', context), SizedBox(height: 10,),
                              monitoreo("Pays", const Color.fromARGB(255, 235, 134, 33), Colors.white, 'https://cdn-icons-png.flaticon.com/512/1019/1019607.png', '1', context),
                          ],
                          
                        ),
                      ),
                    ],
                  ),
                ),
        ),
        Expanded(
          
          child: Column(
            children: [
              Expanded(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  decoration: BoxDecoration(
                    color:Color.fromARGB(255, 212, 221, 225),
                  ),
                  padding: EdgeInsets.only(left:20, bottom: 20, right: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:[

                            Text("Recent Patients", style: TextStyle(fontSize: 30, color: Colors.black),),
                            SizedBox(height: 10,),

                            SizedBox(
                            height: MediaQuery.of(context).size.height*0.4, 
                            child:ListView( shrinkWrap: true,
                              physics: AlwaysScrollableScrollPhysics(),
                              children:[
                                pacientes("Luna", "Golden Retriever", "Updated 20 min ago", Colors.white, Colors.black, 'https://cdn-icons-png.freepik.com/512/3093/3093440.png', 'https://cdn-icons-png.flaticon.com/512/8260/8260706.png', 'https://png.pngtree.com/png-clipart/20230427/original/pngtree-world-red-cross-day-pin-badge-png-image_9115857.png','Next appointment: today, 3:00PM', "Fever and vomiting", context), SizedBox(height: 10,),
                                pacientes("Max", "Siamese Cat", "Updated 1 hour ago", Colors.white, Colors.black, 'https://cdn-icons-png.freepik.com/512/4644/4644948.png', 'https://cdn-icons-png.flaticon.com/512/8260/8260706.png', 'https://png.pngtree.com/png-clipart/20230427/original/pngtree-world-red-cross-day-pin-badge-png-image_9115857.png','Next appointment: today, 3:00PM', "Annual Vaccination", context), SizedBox(height: 10,),
                                
                              ]
                            )
                          ),
                              
                    ]
                  )
                )
              ),
              
            ],
          )
        ),
        

        
        ],
      ),


      
    );

}
   Widget monitoreo(String contenido, Color color, Color colorTexto, String imagen,String textoFinal,BuildContext context){
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 70,
      padding: EdgeInsets.all(5),
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
                
                Text(contenido, style: TextStyle(color: colorTexto, fontSize: 20,),),
                
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            
            children:[
              Padding(padding: EdgeInsets.only(right: 15),
              child:Text(textoFinal, style:TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700))
              )
            ],),

          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            
            children:[
              Padding(padding: EdgeInsets.only(right: 5),
              child:Icon(Icons.chevron_right, color: Colors.white),
              )
            ],),
            
        ]
      )

    );
  }

  Widget pacientes(String titulo, String contenido, String subtitulo, Color color, Color colorTexto, String imagen,String imagen2,String imagen3,String titulo2,String titulo3,BuildContext context){
    return 
        Container(
          width: MediaQuery.of(context).size.width,
          //height: 141,
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          child: Column(
            children:[
              Row(
            //mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipOval(child: Image.network(imagen, width: 50, height: 60,),),
              SizedBox(width: 15),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children:[
                    Text(titulo, style: TextStyle(color: colorTexto, fontSize: 20,fontWeight: FontWeight.w700),),
                    Text(contenido, style: TextStyle(color: colorTexto, fontSize: 15, )),
                    Text(subtitulo, style: TextStyle(color: colorTexto, fontSize: 15),)
                  ],
                ),
              ),
            ],
          ),
          Divider(height: 1,color: Colors.grey[350]),
          Row(children: [
          
          Padding(
            padding: EdgeInsets.only(top:7, bottom:5),
            child: Image.network(imagen2, width: 25, height: 20),
          ),
          SizedBox(width: 10,),
          
          Expanded(
            child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  
                  children:[
                    Text(titulo2, style: TextStyle(color: colorTexto, fontSize: 15,fontWeight: FontWeight.w700),),

                  ],
                ),
              ),
              
            ],
          ),
          Row(children: [
            Image.network(imagen3, width: 25, height: 20,),
            SizedBox(width: 10,),

          Expanded(
            child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children:[
                    Text(titulo3, style: TextStyle(color: colorTexto, fontSize: 15, fontWeight: FontWeight.w700),)
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey),
          ])
        ],
      ),
    );
  }
}