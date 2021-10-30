//----------------------------- ATTACHES
deltaVide= 0.2;
rayonArrondi = 0.5;
epaisseurCubeContenant = 0.11;
largeur4attachesPriseFemelle = 0.18;
diametreCablePrise = 0.61;
//----------------------------- RELAY
largeurTrouRelay = 6.31;
profondeurTrouRelay = 2.42;
hauteurTrouRelay = 4.59;
epaisseurParoisRelay = 0.15;
//----------------------------- TRANSFO
largeurTrouTansfo = 5.7;
profondeurTrouTransfo = 1.68;
hauteurTrouTransfo = 1.15;
epaisseurParoisTransfo = 0.15;
decalageGaucheBord = 0.7;
//----------------------------- ESP8266
largeurTrouESP = 2.5;
largeurTrouESP2 = 0.54;
profondeurTrouESP1 = 1.15;
profondeurTrouESP2 = 1.5;
hauteurTrouESP = 0.59;
epaisseurParoisESP = 0.15;
decalageGaucheBordESP = 0.7;
//----------------------------- PRISE FEMELLE
profondeurCube = 6.21;//cm
hauteurCube = hauteurTrouRelay+epaisseurCubeContenant;
largeurCube = 7.22;

//----------------------------- CUBE Contenant
//variable solide
largeurCubeContenant = largeurCube+(2*largeur4attachesPriseFemelle)+(2*epaisseurCubeContenant);
profondeurCubeContenant = profondeurCube+(2*epaisseurCubeContenant)+profondeurTrouTransfo+profondeurTrouRelay+(2*epaisseurCubeContenant);
hauteurCubeContenant = hauteurCube;
//variable vide du cube solide
largeurCubeContenantVider = largeurCubeContenant-(2*epaisseurCubeContenant)-(2*largeur4attachesPriseFemelle);
profondeurCubeContenantVider = profondeurCubeContenant-(2*epaisseurCubeContenant);
hauteurCubeContenantVider = hauteurCubeContenant-epaisseurCubeContenant+deltaVide;

//attache verticale----------------------------
rayonAttacheCylind=0.4;
decal = 0.25;
hauteurAttacheCylind = hauteurCubeContenant;

//-------------------------------------------------------------------------
//
// Cube principale, vidé par les différents emplacements des composants
//
//-------------------------------------------------------------------------

difference(){
    union(){
        //Partie solide ------
        translate([0,(profondeurCubeContenant/2)-(profondeurCube/2)-profondeurTrouTransfo-2*
        epaisseurCubeContenant,0])
        translate([0,0,-epaisseurCubeContenant+hauteurCubeContenant/2])
        color("green")
        cube(size = [largeurCubeContenant, profondeurCubeContenant, hauteurCubeContenant], center = true, $fn=100); 
 
      
    }
    union(){
        //vidage simplement (et laisser de la matière pour les attaches de la rprise femelle) le cube contenant
        troueCubiquePourCubeContenant();
        
        troueHAUTCubiquePourCubeContenant();
        
        //vider les 4 attaches rectangulaire de la prise femelle
        4attachesPriseFemelle();
        
        //vider la base cubique de la prise femelle ---------
        troueCubiquePourPriseFemelle();
        
        //vidage des 4 coins
        4petitsCarresPourLaisserArrondi();
        
        //troue de la prise male de face
        trouPriseMale();
    }
}//difference(){ de CUBE contenant

4arrondiDuCube();//côtés arrondi
completerTroueArrondi();//remplir les trous de la base causé par le vidage des arrondis 
translate([0.065,0,0]) emplacementTransfo();
//emplacementESP8266();
attachesVerticalesFace();//pour le cube de base
attachesVerticalesArriere();//attaches cylindriques pour le cube de base
emplacementRelay();

//-------------------------------------------------------------------------
//
// FIN Cube principale, vidé par les différents emplacements des composants
//
//-------------------------------------------------------------------------


//-------------------------------------------------------------------------
//
// Couvercle 
//
//-------------------------------------------------------------------------

epaisseurBaseCouvert= epaisseurCubeContenant -0.05;

diametreVisCouvercle = 0.3;
deltaHauteurCouvercle = 1.5; //une hauteur pour visibilité lors de la conception
decalageVerticalPourVisibilite=((epaisseurCubeContenant+hauteurCubeContenant)/2)+deltaHauteurCouvercle;
translate ([0,0,decalageVerticalPourVisibilite])

difference(){
    union(){
        //Partie solide ------
        translate([0,(profondeurCubeContenant/2)-(profondeurCube/2)-        profondeurTrouTransfo-2*    
        epaisseurCubeContenant,0])
        translate([0,0,-epaisseurCubeContenant+hauteurCubeContenant/2])
        color("green")
        cube(size = [largeurCubeContenant, profondeurCubeContenant,         epaisseurCubeContenant], 
        center = true, $fn=100); 
        

        //le vidage des arrondis         
 
      
    }
    union(){
        //vidage des 4 coins
        4petitsCarresPourLaisserArrondi();
        //vider les trous pour vis de couvercle
            translate ([0,0,-3+hauteurCubeContenant+deltaHauteurCouvercle-decalageVerticalPourVisibilite])
                attachesVerticalesFaceVisagePourVis(diametreVisCouvercle);
            translate ([0,0,-3+hauteurCubeContenant+deltaHauteurCouvercle-decalageVerticalPourVisibilite])
                attachesVerticalesArriereVidagePourVis(diametreVisCouvercle);        

        //vidage pour tests =============================== MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
        //translate ([0,4.2,6])
        //translate ([0,3.8,0])
        //    cube (size=[10,5,5], center=true);
        //translate ([0,-4,0])
        //    cube (size=[10,5,5], center=true);
        //fin vidage pour tests ============================= MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
       
    }
}
//remplissage des coins arrondis et vidage de trous de vis
//**********************************************************
difference(){
    union(){
            //remplir les trous carrée de la base causé par le vidage carrée 
            //des coins
            translate ([0,-0.04,hauteurCubeContenant+deltaHauteurCouvercle])
                completerTroueArrondi();
    }
    union(){
        //vider les trous pour vis de couvercle
            translate ([0,0,-3+hauteurCubeContenant+deltaHauteurCouvercle])
                attachesVerticalesFaceVisagePourVis(diametreVisCouvercle);
            translate ([0,0,-3+hauteurCubeContenant+deltaHauteurCouvercle])
                attachesVerticalesArriereVidagePourVis(diametreVisCouvercle);

        //vidage pour tests =============================== MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
        //translate ([0,4.2,6])
        //    cube (size=[10,5,5], center=true);
        //translate ([0,-4.2,6])
        //    cube (size=[10,5,5], center=true);
        //fin vidage pour tests ============================= MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
        
    }
}//fin diff pour les coins



//Emplacement alimentation
//***********************************************************
deltaVideAlim= 0.1;
decalageBordFaceAlim = 3;
decalageBordDroitAlim = 2.6;
largeurAlim = 1.68;//OK
heuteurAlim = 2.11+0.06;//OK
profondeurAlim = 1.68;//OK
epaisseurParoisAlim = 0.1;
difference(){
    translate([decalageBordDroitAlim,0,0]) alim();
    union(){
        //vidage pour tests =============================== MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
        //translate ([0,-3.5,6])
        //    cube (size=[10,4,5], center=true);
    }
}
//Alim    
module alim(){
    translate([0,decalageBordFaceAlim,0])
    translate([0,0,hauteurCubeContenant+deltaHauteurCouvercle])
        translate([0,-(profondeurCube/2)
                      -epaisseurCubeContenant-profondeurTrouTransfo
                      -epaisseurParoisTransfo,0])//décalage horizontal 
        translate([0,0,heuteurAlim/2])
        translate([0,profondeurAlim/2,0])
        difference(){
            //cube plein
            color([1,0,0])
            cube(size = [largeurAlim+2*epaisseurParoisAlim,profondeurAlim,heuteurAlim+epaisseurParoisAlim], center = true, $fn=100);
            //cube vide
            cube(size = [largeurAlim,profondeurAlim+deltaVideAlim,heuteurAlim], center = true, $fn=100);            
        }
 }
 
 //Emplacement esp8266
//***********************************************************
deltaVideESPblock= 0.1;
decalageBordFaceESPblock = 5.5;
decalageBordDroitESPblock = -3.2;
largeurESPblock = 0.25;//OK
heuteurESPblock = 1.45+0.05;//OK
profondeurESPblock = 1.82;//OK
epaisseurParoisESPblock = 0.1;
difference(){
    translate([decalageBordDroitESPblock,0,0]) ESPblock();
    union(){
        //vidage pour tests =============================== MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
        //translate ([0,3.3,6])
        //    cube (size=[10,4,5], center=true);
    }    
}
//ESPblock    
module ESPblock(){
    translate([0,decalageBordFaceESPblock,0])
    translate([0,0,hauteurCubeContenant+deltaHauteurCouvercle])
        translate([0,-(profondeurCube/2)
                      -epaisseurCubeContenant-profondeurTrouTransfo
                      -epaisseurParoisTransfo,0])//décalage horizontal 
        translate([0,0,heuteurESPblock/2])
        translate([0,profondeurESPblock/2,0])
        difference(){
            //cube plein
            color([1,0,0])
            cube(size = [largeurESPblock+2*epaisseurParoisESPblock,profondeurESPblock,heuteurESPblock+epaisseurParoisESPblock], center = true, $fn=100);
            //cube vide
            cube(size = [largeurESPblock,profondeurESPblock+deltaVideESPblock,heuteurESPblock], center = true, $fn=100);            
        }
 }

//Emplacement du domino du couvercle
//**********************************************************
decalageBordFaceDomino = 1;
largeurDomino = 2.32;
heuteurDomino = 1.75;
profondeurDomino = 2.12;
epaisseurParoisDomino = 0.15;
domino();//décomenter =============================== MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
//Domino    
module domino(){
    translate([0,decalageBordFaceDomino,0])
    translate([0,0,hauteurCubeContenant+deltaHauteurCouvercle])
        translate([0,-(profondeurCube/2)
                      -epaisseurCubeContenant-profondeurTrouTransfo
                      -epaisseurParoisTransfo,0])//décalage horizontal 
        translate([0,0,heuteurDomino/2])
        translate([0,profondeurDomino/2,0])
        difference(){
            //cube plein
            color([1,0,0])
            cube(size = [largeurDomino+2*epaisseurParoisDomino,profondeurDomino,heuteurDomino+epaisseurParoisDomino], center = true, $fn=100);
            //cube vide
            cube(size = [largeurDomino,profondeurDomino+deltaVide,heuteurDomino], center = true, $fn=100);            
        }
    }        
//FIN Emplacement du domino du couvercle
//**********************************************************
//Emplacement des attaches cables (pour Transfo, Relai & ESP)
//**********************************************************
decalageBordFaceAttachesFils = 1;
largeurAttachesFils = 0.53;
heuteurAttachesFils = 0.4;
profondeurAttachesFils = 0.3;
epaisseurParoisAttachesFils = 0.1;
//decomenter tout le bloc suivant ========================== MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
//haut milieu
//
//rotate([0,0,90])
//    translate([2.7,2.3,0]) 
//    trouesPourFilsCouvercle();
//rotate([0,0,90])
//    translate([2.04,2.3,0]) 
//    trouesPourFilsCouvercle();    
//gauche haut
//translate([-2,5.45,0]) trouesPourFilsCouvercle();
//translate([-2.64,5.45,0]) trouesPourFilsCouvercle();    
//gauche bas
//translate([-2,1,0]) trouesPourFilsCouvercle();
//translate([-2.64,1,0]) trouesPourFilsCouvercle();
//    
//AttachesFils    
module trouesPourFilsCouvercle(){
    color("blue")
    translate([0,decalageBordFaceAttachesFils,0])
    translate([0,0,hauteurCubeContenant+deltaHauteurCouvercle])
        translate([0,-(profondeurCube/2)
                      -epaisseurCubeContenant-profondeurTrouTransfo
                      -epaisseurParoisTransfo,0])//décalage horizontal 
        translate([0,0,heuteurAttachesFils/2])
        translate([0,profondeurAttachesFils/2,0])
        difference(){
            //cube plein
            color([1,0,0])
            cube(size = [largeurAttachesFils+2*epaisseurParoisAttachesFils,profondeurAttachesFils,heuteurAttachesFils+1.5*epaisseurParoisAttachesFils], center = true, $fn=100);
            //cube vide
            cube(size = [largeurAttachesFils,profondeurAttachesFils+deltaVide,heuteurAttachesFils], center = true, $fn=100);            
        }
    }        
//FIN Emplacement des attaches cables (pour Transfo, Relai & ESP)
//**********************************************************    
//Emplacement du bloqueur de prise femelle
//**********************************************************
largeurBloqueurX = 2.74;
hauteurBloqueurX = 1.01;
profondeurBloqueurX = 0.84;
largeurBloqueurY = 2.74;
hauteurBloqueurY = 1.01+0.31;
profondeurBloqueurY = 0.43;

bloqueurPriseFemelle();//decomenter la ligne ============= MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM

module bloqueurPriseFemelle(){    
        color([1,0,0])
        translate([0,0,hauteurCubeContenant+deltaHauteurCouvercle])//le mettre au niveau du couvecle en hauteur
        
        union(){
            //bloqueur axe des X
            translate([0,0,hauteurBloqueurX/2]) //le mettre au niveau 0 de l'axe des Z
            cube(size = [largeurBloqueurX,profondeurBloqueurX,hauteurBloqueurX], center = true, $fn=100);
            //bloqueur axe des Y
            translate([0,0,hauteurBloqueurY/2]) //le mettre au niveau 0 de l'axe des Z
            rotate([0,0,90])
            cube(size = [largeurBloqueurY,profondeurBloqueurY,hauteurBloqueurY], center = true, $fn=100);        
        }
}        
//FIN Emplacement du bloqueur de prise femelle
//**********************************************************        
//Emplacement du bloqueur de parois
//**********************************************************
largeurBloqueurBords = 0.15;
hauteurBloqueurBords = 0.15;
deltaErrorBords = 0.03;
profondeurBloqueurBords = largeurCube;
bloqueurParois();//decomenter la ligne ============= MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
module bloqueurParois(){
    translate([0,0,hauteurCubeContenant+deltaHauteurCouvercle])//le mettre au niveau du couvecle en hauteur
        translate([0,0,hauteurBloqueurBords/2]) //le mettre au niveau 0 de l'axe des Z
        color([1,0,0])
        union(){
            //bord droit
            translate([(-largeurCubeContenant/2)+(largeurBloqueurBords/2)
            +epaisseurCubeContenant+deltaErrorBords,0,0])
            cube(size = [largeurBloqueurBords,profondeurBloqueurBords,hauteurBloqueurBords], center = true, $fn=100);
            //bord gauche
            translate([(+largeurCubeContenant/2)-(largeurBloqueurBords/2)
            -epaisseurCubeContenant-deltaErrorBords,0,0])
            cube(size = [largeurBloqueurBords,profondeurBloqueurBords,hauteurBloqueurBords], center = true, $fn=100);
        }
}

//FIN Emplacement du bloqueur de parois
//**********************************************************

//-------------------------------------------------------------------------
//
// Fin Couvercle 
//
//-------------------------------------------------------------------------




//Attaches verticales$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

module attachesVerticalesFace(){
difference(){
    //2 attaches verticales en bas
    union(){
            color("black")
            translate([0,-rayonAttacheCylind,0])
                //gauche -->
                translate([(-largeurCubeContenant/2)+(rayonAttacheCylind/2)+decal,0,0])
                //bas:
                translate([0,-(profondeurCube/2)-epaisseurParoisRelay-profondeurTrouTransfo+2*rayonAttacheCylind-0.15,0])
                    translate([0,0,(hauteurAttacheCylind/2)-epaisseurCubeContenant])
                    cylinder (h = hauteurAttacheCylind, r=rayonAttacheCylind, center = true, $fn=100); 
            //bas droite
            color("black")
            translate([0,-rayonAttacheCylind,0])
                //droite -->
                translate([(largeurCubeContenant/2)-(rayonAttacheCylind/2)-decal,0,0])
                //bas:
                translate([0,-(profondeurCube/2)-epaisseurParoisRelay-profondeurTrouTransfo+2*rayonAttacheCylind-0.15,0])
                    translate([0,0,(hauteurAttacheCylind/2)-epaisseurCubeContenant])
                    cylinder (h = hauteurAttacheCylind, r=rayonAttacheCylind, center = true, $fn=100);        
    }
    //trous 2 attaches verticales en bas
    union(){
            
            translate([0,-rayonAttacheCylind,0])
                //gauche -->
                translate([(-largeurCubeContenant/2)+(rayonAttacheCylind/2)+decal,0,0])
                //bas:
                translate([0,-(profondeurCube/2)-epaisseurParoisRelay-profondeurTrouTransfo+2*rayonAttacheCylind-0.15,0])
                    translate([0,0,(hauteurAttacheCylind/2)-epaisseurCubeContenant])
                    cylinder (h = hauteurAttacheCylind, r=0.15, center = true, $fn=100); 
            //bas droite
            
            translate([0,-rayonAttacheCylind,0])
                //droite -->
                translate([(largeurCubeContenant/2)-(rayonAttacheCylind/2)-decal,0,0])
                //bas:
                translate([0,-(profondeurCube/2)-epaisseurParoisRelay-profondeurTrouTransfo+2*rayonAttacheCylind-0.15,0])
                    translate([0,0,(hauteurAttacheCylind/2)-epaisseurCubeContenant])
                    cylinder (h = hauteurAttacheCylind, r=0.15, center = true, $fn=100);        
    }
}//fin diff
}//attachesVerticalesFace(){

module attachesVerticalesArriere(){
    difference(){
        //2 attaches verticales en bas
        union(){
            //haut droit
            color("black")
            translate([0,-rayonAttacheCylind,0])
                //droite -->
                translate([(largeurCubeContenant/2)-(rayonAttacheCylind/2)-decal,0,0])
                //haut:
                translate([0,(profondeurCube/2)+epaisseurParoisRelay+profondeurTrouRelay+       
            epaisseurCubeContenant,0])
                    translate([0,0,(hauteurAttacheCylind/2)-epaisseurCubeContenant])
                    cylinder (h = hauteurAttacheCylind, r=rayonAttacheCylind-0.065, center = true, $fn=100);
            //haut gauche
            color("black")
            translate([0,-rayonAttacheCylind,0])
                //gauche -->
                translate([(-largeurCubeContenant/2)+(rayonAttacheCylind/2)+decal,0,0])
                //haut:
                translate([0,(profondeurCube/2)+epaisseurParoisRelay+profondeurTrouRelay+       
                epaisseurCubeContenant,0])
                    translate([0,0,(hauteurAttacheCylind/2)-epaisseurCubeContenant])
                    cylinder (h = hauteurAttacheCylind, r=rayonAttacheCylind-0.065, center = true, $fn=100            );             
        }
        union(){
        //troue haut droit
        color([0,0.9,0])
        translate([0,-rayonAttacheCylind,0])
            //droite -->
            translate([(largeurCubeContenant/2)-(rayonAttacheCylind/2)-
            decal,0,0])
            //haut:
            translate([0,(profondeurCube/2)+epaisseurParoisRelay+
            profondeurTrouRelay+epaisseurCubeContenant,0])
                translate([0,0,(hauteurAttacheCylind/2)-    
                epaisseurCubeContenant])
                cylinder (h = hauteurAttacheCylind, r=0.15, center = true, 
                $fn=100);
        //troue haut gauche
        color([0,0.9,0])
        translate([0,-rayonAttacheCylind,0])
            //gauche -->
            translate([(-largeurCubeContenant/2)+(rayonAttacheCylind/2)+
            decal,0,0])
            //haut:
            translate([0,(profondeurCube/2)+epaisseurParoisRelay+
            profondeurTrouRelay+       
            epaisseurCubeContenant,0])
                translate([0,0,(hauteurAttacheCylind/2)-
                epaisseurCubeContenant])
                cylinder (h = hauteurAttacheCylind, r=0.15, center = true, 
                $fn=100);
        //vidage principale pour le cube du relais
        viderPrincipalCubeRelay();


                
        }    
    }
}//fin attachesVerticalesFace(){



//vidage principale pour le cube du relais
module viderPrincipalCubeRelay(){
        color("blue")
        translate([0,epaisseurParoisRelay,0])
        translate([0,+(profondeurTrouRelay/2),0])
        translate([0,profondeurCube/2,0])
        translate([0,0,(hauteurTrouRelay+deltaVide)/2])
        cube(size = [largeurTrouRelay, profondeurTrouRelay, hauteurTrouRelay+deltaVide], center = true, $fn=100);
}

//vider les trous de vis pour couvercle de face:
module attachesVerticalesFaceVisagePourVis(diamVis){
    //trous 2 attaches verticales en bas
    union(){
            
            translate([0,-rayonAttacheCylind,0])
                //gauche -->
                translate([(-largeurCubeContenant/2)+(rayonAttacheCylind/2)+decal,0,0])
                //bas:
                translate([0,-(profondeurCube/2)-epaisseurParoisRelay-profondeurTrouTransfo+2*rayonAttacheCylind-0.15,0])
                    translate([0,0,(hauteurAttacheCylind/2)-epaisseurCubeContenant])
                    cylinder (h = hauteurAttacheCylind, r=diamVis/2, center = true, $fn=100); 
            //bas droite
            
            translate([0,-rayonAttacheCylind,0])
                //droite -->
                translate([(largeurCubeContenant/2)-(rayonAttacheCylind/2)-decal,0,0])
                //bas:
                translate([0,-(profondeurCube/2)-epaisseurParoisRelay-profondeurTrouTransfo+2*rayonAttacheCylind-0.15,0])
                    translate([0,0,(hauteurAttacheCylind/2)-epaisseurCubeContenant])
                    cylinder (h = hauteurAttacheCylind, r=diamVis/2, center = true, $fn=100);        
    }
}//attachesVerticalesFaceVisagePourVis{



//vider les trous de vis pour couvercle arrière:
module attachesVerticalesArriereVidagePourVis(diamVis){
        union(){
        //troue haut droit
        color([0,0.9,0])
        translate([0,-rayonAttacheCylind,0])
            //droite -->
            translate([(largeurCubeContenant/2)-(rayonAttacheCylind/2)-
            decal,0,0])
            //haut:
            translate([0,(profondeurCube/2)+epaisseurParoisRelay+
            profondeurTrouRelay+epaisseurCubeContenant,0])
                translate([0,0,(hauteurAttacheCylind/2)-    
                epaisseurCubeContenant])
                cylinder (h = hauteurAttacheCylind, r=diamVis/2, center = true, 
                $fn=100);
        //troue haut gauche
        color([0,0.9,0])
        translate([0,-rayonAttacheCylind,0])
            //gauche -->
            translate([(-largeurCubeContenant/2)+(rayonAttacheCylind/2)+
            decal,0,0])
            //haut:
            translate([0,(profondeurCube/2)+epaisseurParoisRelay+
            profondeurTrouRelay+       
            epaisseurCubeContenant,0])
                translate([0,0,(hauteurAttacheCylind/2)-
                epaisseurCubeContenant])
                cylinder (h = hauteurAttacheCylind, r=diamVis/2, center = true, 
                $fn=100);            
        }
}
//troue pour la prise male
module trouPriseMale(){
    translate([0,0,hauteurCube-diametreCablePrise])
    translate([0,-5,0])
    rotate(a=[90,0,0])
    cylinder (h = 3, r=(diametreCablePrise/2), center = true, $fn=100); 
} 




//vider l'emplacement du Relay ---------
//-------------------------------------------
module emplacementRelay(){
difference(){
    union(){
        //cube principal
        color([0,0.9,0])
        translate([0,epaisseurParoisRelay,0])
        translate([0,+(profondeurTrouRelay/2),0])
        translate([0,profondeurCube/2,0])
        translate([0,-(epaisseurParoisRelay/2),(hauteurTrouRelay)/2])
        cube(size = [largeurTrouRelay+(2*epaisseurParoisRelay), profondeurTrouRelay+epaisseurParoisRelay,    hauteurTrouRelay], center = true, $fn=100); 

//bare faciale du Relais de bout en bout ----------
//-------------------------------------------------
        deplVertical3 = 2.89;
        trouFilHaut3 = 1.78;        
        color("green")
        translate([0,0,-1])
        translate([0,+(epaisseurParoisRelay/2),0])
        translate([0,profondeurCube/2,0])
        translate([0,0,deplVertical3+(trouFilHaut3)/2])
            cube(size = [largeurCubeContenant, epaisseurParoisRelay, trouFilHaut3], center = true, $fn=100
            ); 

        
    }
    union(){
        //vidage principale du cube
        viderPrincipalCubeRelay();
        
        //troue pour les deux fil d'en bas
        deplVertical1 = 0.35;
        trouFilHaut = 1.18;
        profondTrouFil = 1;
        //troue pour les 2 fils d'en bas
        color("red")
        translate([0,epaisseurParoisRelay,0])
        translate([0,+(profondTrouFil/2),0])
        translate([0,profondeurCube/2,0])
        translate([0,0,deplVertical1+(trouFilHaut)/2])
            cube(size = [2*largeurTrouRelay, profondTrouFil, trouFilHaut], center = true, $fn=100
            );
            
        //troue pour les 2 fils d'en haut
        deplVertical2 = 1.09;
        trouFilHaut2 = 3.58;        
        color("yellow")
        translate([0,epaisseurParoisRelay,0])
        translate([0,+(profondTrouFil/2),0])
        translate([0,profondeurCube/2,0])
        translate([0,0,deplVertical2+(trouFilHaut2)/2])
            cube(size = [2*largeurTrouRelay, profondTrouFil, trouFilHaut2], center = true, $fn=100
            );       

        //troue pour enlever la partie haute de la face du relais
        deplVertical3 = 2.89;
        trouFilHaut3 = 1.78;        
        color("green")
        translate([0,epaisseurParoisRelay,0])
        translate([0,+(profondTrouFil/2),0])
        translate([0,-0.9+profondeurCube/2,0])
        translate([0,0,deplVertical3+(trouFilHaut3)/2])
            cube(size = [2*largeurTrouRelay, profondTrouFil, trouFilHaut3], center = true, $fn=100
            );

       //3 troues d'aération
       //1. trou carré gauche
        largeurAeration = 1;
        color("yellow")
        translate([-(largeurTrouRelay-largeurAeration-1)/2,0,0])
        translate([0,epaisseurParoisRelay,0])
        translate([0,+(profondTrouFil/2),0])
        translate([0,profondeurCube/2,0])
        translate([0,0,(trouFilHaut)/2])
            cube(size = [largeurAeration, 2*profondTrouFil, trouFilHaut], center = true, $fn=100
            );
       //2.trou carré droit
        largeurAeration = 1; 
        color("yellow")
        translate([+(largeurTrouRelay-largeurAeration-1)/2,0,0])
        translate([0,epaisseurParoisRelay,0])
        translate([0,+(profondTrouFil/2),0])
        translate([0,profondeurCube/2,0])
        translate([0,0,(trouFilHaut)/2])
            cube(size = [largeurAeration, 2*profondTrouFil, trouFilHaut], center = true, $fn=100
            ); 
       //3. trou carré milieu
        largeurAeration = 1.3;
        color("yellow")
        translate([0,epaisseurParoisRelay,0])
        translate([0,+(profondTrouFil/2),0])
        translate([0,profondeurCube/2,0])
        translate([0,0,(trouFilHaut)/2])
            cube(size = [largeurAeration, 2*profondTrouFil, trouFilHaut], center =  
            true, $fn=100);             
        
        //Cylindre d'aération et d'économie de plastique
        hc=2;
        decalageVertCylinder = 1.8;
        translate([0,0,decalageVertCylinder]) //le décaler en haut
        translate([0,profondeurCube/2,0])//le mettre au niveau de la parois int. 
                                         //du relai
        translate([0,0,hc/2]) //niveau 0 de l'axe des Z
        rotate([90,0,0])
        scale([2.5, 1, 1])
        cylinder (h = hc, r=1, center = true, $fn=100);
    }    
}//fin difference(){ de l'emplacement des relay
}

//vider l'emplacement du transfo ---------
//-------------------------------------------
module emplacementTransfo(){
difference(){
    union(){

            color([0,0.9,0])
            translate([decalageGaucheBord-(largeurCube/2)+(largeurTrouTansfo/2),0,0])
            translate([0,-epaisseurParoisTransfo,0])
            translate([0,-(profondeurTrouTransfo/2),0])
            translate([0,-profondeurCube/2,0])
            translate([0,+(epaisseurParoisRelay/2),hauteurTrouTransfo/2])
            cube(size = [largeurTrouTansfo+(2*epaisseurParoisTransfo), profondeurTrouTransfo+epaisseurParoisTransfo, hauteurTrouTransfo], center = true, $fn=100); 
        
    }
    union(){
            color("blue")
            translate([decalageGaucheBord-(largeurCube/2)+(largeurTrouTansfo/2),0,0])
            translate([0,-epaisseurParoisTransfo,0])
            translate([0,-(profondeurTrouTransfo/2),0])
            translate([0,-profondeurCube/2,0])
            translate([0,0,(hauteurTrouTransfo+deltaVide)/2])
            cube(size = [largeurTrouTansfo, profondeurTrouTransfo, hauteurTrouTransfo+deltaVide], 
            center = true, $fn=100);
            //pour les troues des fils
            color("blue")
            translate([decalageGaucheBord-(largeurCube/2)+(largeurTrouTansfo/2),0,0])
            translate([0,-epaisseurParoisTransfo-profondeurTrouTransfo,0])
            translate([0,+((profondeurTrouTransfo)/2),0])
            translate([0,-profondeurCube/2,0])
            translate([0,0,(1*(hauteurTrouTransfo/3))/2])
            cube(size = [largeurTrouTansfo+2, profondeurTrouTransfo, 1*(hauteurTrouTransfo/3)], 
            center = true, $fn=100);

            color("yellow")
            translate([decalageGaucheBord-(largeurCube/2)+(largeurTrouTansfo/2),0,0])
            translate([0,-epaisseurParoisTransfo-profondeurTrouTransfo,0])
            translate([0,+((profondeurTrouTransfo/3)/2),0])
            translate([0,-profondeurCube/2,0])
            translate([0,0,(1.5*(hauteurTrouTransfo/3))/2])
            cube(size = [largeurTrouTansfo/3, 3*profondeurTrouTransfo, 2.9*(hauteurTrouTransfo/3)], 
            center = true, $fn=100);        
    }
}//fin diff espace transfo
}





//vider l'emplacement du ESP8266 ---------
//-------------------------------------------
module emplacementESP8266(){
translate([0,0,0])
difference(){
    union(){
        //solide ESP long
        color([0,0.9,0])
        translate([-decalageGaucheBordESP+(largeurCube/2)-(largeurTrouESP/2),0,0])
        translate([0,-2*epaisseurParoisESP,0])
        translate([0,-(profondeurTrouESP2/2),0])
        translate([0,-profondeurCube/2,0])
        translate([0,0,hauteurTrouESP/2])
        cube(size = [largeurTrouESP+2*epaisseurParoisESP, profondeurTrouESP2+2*epaisseurParoisESP
        , hauteurTrouESP], center = true, $fn=100);
    
        //solide ESP court
        //color([0,0.9,0])
        //translate([-decalageGaucheBordESP+(largeurCube/2)-(largeurTrouESP2/2),0,0])
        //translate([0,-epaisseurParoisESP,0])
        //translate([0,-(profondeurTrouESP1/2),0])
        //translate([0,-profondeurCube/2,0])
        //translate([0,0,hauteurTrouESP/2])
        //cube(size = [largeurTrouESP2+2*epaisseurParoisESP, profondeurTrouESP1, 
       
    }
    union(){
        //vide ESP long
        color("blue")
        translate([-decalageGaucheBordESP+(largeurCube/2)-(largeurTrouESP/2),0,0])
        translate([0,-2*epaisseurParoisESP,0])
        translate([0,-(profondeurTrouESP2/2),0])
        translate([0,-profondeurCube/2,0])
        translate([0,0,(hauteurTrouESP+deltaVide)/2])
        cube(size = [largeurTrouESP, profondeurTrouESP2, hauteurTrouESP+deltaVide], center = true
        , $fn=100);

        color("yellow")
        translate([-decalageGaucheBordESP+(largeurCube/2)-(largeurTrouESP/2),0,0])
        translate([0,-2*epaisseurParoisESP,0])
        translate([0,-(profondeurTrouESP2/2),0])
        translate([0,-profondeurCube/2,0])
        translate([0,0,(hauteurTrouESP+deltaVide)/2])
        cube(size = [largeurTrouESP/2, 2*profondeurTrouESP2, hauteurTrouESP+deltaVide], center = true
        , $fn=100);
        //vide ESP court
       
    }
}//fin difference(){
}











//Vidage des 4 petits carrée pour laisser les arrondis
module 4petitsCarresPourLaisserArrondi(){
//vidage des 4 troues carrées pour mettre un arrondi
//1. carrée droit haut
carreVideurArrondiHauteur = hauteurCubeContenant;
color("blue")
translate([0,(profondeurCube/2)+epaisseurParoisRelay+profondeurTrouRelay+epaisseurCubeContenant-rayonArrondi,0])
translate([epaisseurCubeContenant+largeur4attachesPriseFemelle+(largeurCubeContenantVider
        )/2,0,0])
translate([-rayonArrondi/2,rayonArrondi/2,0])
    translate([0.1,0.1,-epaisseurCubeContenant+hauteurCubeContenant/2])
    cube(size=[rayonArrondi+0.1,rayonArrondi+0.1,hauteurCubeContenant+1], center = true, $fn=100);

//2. carrée gauche haut
color("blue")
translate([0,(profondeurCube/2)+epaisseurParoisRelay+profondeurTrouRelay+epaisseurCubeContenant-rayonArrondi,0])
translate([-epaisseurCubeContenant-largeur4attachesPriseFemelle-(largeurCubeContenantVider
        )/2,0,0])
translate([rayonArrondi/2,rayonArrondi/2,0])
    translate([-0.1,0.1,-epaisseurCubeContenant+hauteurCubeContenant/2])
    cube(size=[rayonArrondi+0.1,rayonArrondi+0.1,hauteurCubeContenant+1], center = true, $fn=100);
//3. carrée droit bas
carreVideurArrondiHauteur = hauteurCubeContenant-epaisseurCubeContenant;
color("blue")
translate([0,(profondeurCube/2)+epaisseurParoisRelay+profondeurTrouRelay+epaisseurCubeContenant-rayonArrondi-profondeurCubeContenant+rayonArrondi,0])
translate([epaisseurCubeContenant+largeur4attachesPriseFemelle+(largeurCubeContenantVider
        )/2,0,0])
translate([-rayonArrondi/2,rayonArrondi/2,0])
    translate([0.1,-0.1,-epaisseurCubeContenant+hauteurCubeContenant/2])
    cube(size=[rayonArrondi+0.1,rayonArrondi+0.1,hauteurCubeContenant+1], center = true, $fn=100);
//4. carrée gauche bas
color("blue")
translate([0,(profondeurCube/2)+epaisseurParoisRelay+profondeurTrouRelay+epaisseurCubeContenant-rayonArrondi-profondeurCubeContenant+rayonArrondi,0])
translate([-epaisseurCubeContenant-largeur4attachesPriseFemelle-(largeurCubeContenantVider
        )/2,0,0])
translate([rayonArrondi/2,rayonArrondi/2,0])
    translate([-0.1,-0.1,-epaisseurCubeContenant+hauteurCubeContenant/2])
    cube(size=[rayonArrondi+0.1,rayonArrondi+0.1,hauteurCubeContenant+1], center = true, $fn=100);
}    
    




module 4arrondiDuCube(){
//arondi haut droit
translate([epaisseurCubeContenant+largeur4attachesPriseFemelle+(largeurCubeContenantVider
        )/2,0,0])
translate([0,(profondeurCube/2)+epaisseurParoisRelay+profondeurTrouRelay+epaisseurCubeContenant-rayonArrondi,0])
    
    arrondiHautDroit();

//arondi haut gauche
translate([-epaisseurCubeContenant-largeur4attachesPriseFemelle-(largeurCubeContenantVider
        )/2+2*rayonArrondi,0,0])
translate([0,(profondeurCube/2)+epaisseurParoisRelay+profondeurTrouRelay+epaisseurCubeContenant-rayonArrondi,0])

    arrondiHautGauche();

//arondi bas droit
translate([largeurCubeContenant-2*rayonArrondi,-profondeurCubeContenant+2*rayonArrondi,0])
translate([-epaisseurCubeContenant-largeur4attachesPriseFemelle-(largeurCubeContenantVider
        )/2+2*rayonArrondi,0,0])
translate([0,(profondeurCube/2)+epaisseurParoisRelay+profondeurTrouRelay+epaisseurCubeContenant-rayonArrondi,0])        

    arrondiBasDroit();

//arondi bas gauche
translate([0,-profondeurCubeContenant+2*rayonArrondi,0])
translate([-epaisseurCubeContenant-largeur4attachesPriseFemelle-(largeurCubeContenantVider
        )/2+2*rayonArrondi,0,0])
translate([0,(profondeurCube/2)+epaisseurParoisRelay+profondeurTrouRelay+epaisseurCubeContenant-rayonArrondi,0])

    arrondiBasGauche();
}


module completerTroueArrondi(){
//base arrondi qui complète
arrondiHauteur = hauteurCubeContenant-epaisseurCubeContenant;   
    //solide cylindre
    //1.haut gauche qui complète    
    color ("red")
    translate([-epaisseurCubeContenant-largeur4attachesPriseFemelle-(largeurCubeContenantVider
        )/2+2*rayonArrondi,0,-epaisseurCubeContenant])
    translate([0,(profondeurCube/2)+epaisseurParoisRelay+profondeurTrouRelay+epaisseurCubeContenant-rayonArrondi,0])    
    translate([0,0,epaisseurCubeContenant/2])
    translate([-rayonArrondi,0,0])
    translate([0,0,0])
        cylinder (h = epaisseurCubeContenant, r=rayonArrondi, center = true, $fn=100);
    
    //2.haut droit  qui complète 
    color ("blue")
    translate([epaisseurCubeContenant+largeur4attachesPriseFemelle+(largeurCubeContenantVider
        )/2,0,0])
    translate([0,(profondeurCube/2)+epaisseurParoisRelay+profondeurTrouRelay+epaisseurCubeContenant-rayonArrondi,-epaisseurCubeContenant])   
    translate([0,0,epaisseurCubeContenant/2])
    translate([-rayonArrondi,0,0])
    translate([0,0,0])
        cylinder (h = epaisseurCubeContenant, r=rayonArrondi, center = true, $fn=100);
    
    //3. bas droit  qui complète 
    color ("green")
    translate([largeurCubeContenant-2*rayonArrondi,-profondeurCubeContenant+2*rayonArrondi,0])
    translate([-epaisseurCubeContenant-largeur4attachesPriseFemelle-(largeurCubeContenantVider
        )/2+2*rayonArrondi,0,0])
    translate([0,(profondeurCube/2)+epaisseurParoisRelay+profondeurTrouRelay+epaisseurCubeContenant-rayonArrondi,-epaisseurCubeContenant])    
    translate([0,0,epaisseurCubeContenant/2])
    translate([-rayonArrondi,0,0])
    translate([0,0,0])
        cylinder (h = epaisseurCubeContenant, r=rayonArrondi, center = true, $fn=100);
    
    //4. bas gauche  qui complète 
    color ("green")
    translate([0,-profondeurCubeContenant+2*rayonArrondi,0])
    translate([-epaisseurCubeContenant-largeur4attachesPriseFemelle-(largeurCubeContenantVider
        )/2+2*rayonArrondi,0,0])
    translate([0,(profondeurCube/2)+epaisseurParoisRelay+profondeurTrouRelay+epaisseurCubeContenant-rayonArrondi,-epaisseurCubeContenant])    
    translate([0,0,epaisseurCubeContenant/2])
    translate([-rayonArrondi,0,0])
    translate([0,0,0])
        cylinder (h = epaisseurCubeContenant, r=rayonArrondi, center = true, $fn=100);
    }        
//les arrondi du cube
module arrondiHautDroit(){
difference(){
    arrondiHauteur = hauteurCubeContenant-epaisseurCubeContenant;
    union(){    
        //solide cylindre
        translate([0,0,arrondiHauteur/2])
        translate([-rayonArrondi,0,0])
        translate([0,0,0])
            cylinder (h = arrondiHauteur, r=rayonArrondi, center = true, $fn=100);
        

               
    }
    union(){
        //vide cylindrique du cylindre
        color([0,0,0.7])
        translate([0,0,(arrondiHauteur+deltaVide)/2])
        translate([-rayonArrondi,0,0])
        translate([0,0,0])
            cylinder (h = arrondiHauteur+deltaVide, r=rayonArrondi-epaisseurCubeContenant, center = true, $fn=100);
        //couper un angle droit
        
        translate([-rayonArrondi/2,0,0]) //vidage carrée gauche
        translate([-rayonArrondi,0,(arrondiHauteur+deltaVide)/2])
        translate([0,0,0])        
            cube(size=[rayonArrondi,2*rayonArrondi,arrondiHauteur+deltaVide], center = true, $fn=100);  
        
        translate([-rayonArrondi,-rayonArrondi/2,0]) //vidage carrée bas
        translate([0,0,(arrondiHauteur+deltaVide)/2])
        translate([0,0,0])        
            cube(size=[2*rayonArrondi, rayonArrondi,arrondiHauteur+deltaVide], center = true, $fn=100);        
    }    
}
}//fin module arrondiHautDroit(){

module arrondiBasDroit(){
difference(){
    arrondiHauteur = hauteurCubeContenant-epaisseurCubeContenant;;
    rayonArrondi = 0.5;
    union(){    
        //solide cylindre
        translate([0,0,arrondiHauteur/2])
        translate([-rayonArrondi,0,0])
        translate([0,0,0])
            cylinder (h = arrondiHauteur, r=rayonArrondi, center = true, $fn=100);
        

               
    }
    union(){
        //vide cylindrique du cylindre
        color([0,0,0.7])
        translate([0,0,(arrondiHauteur+deltaVide)/2])
        translate([-rayonArrondi,0,0])
        translate([0,0,0])
            cylinder (h = arrondiHauteur+deltaVide, r=rayonArrondi-epaisseurCubeContenant, center = true, $fn=100);
        //couper un angle droit
        
        translate([-rayonArrondi/2,0,0]) //vidage carrée gauche
        translate([-rayonArrondi,0,(arrondiHauteur+deltaVide)/2])
        translate([0,0,0])        
            cube(size=[rayonArrondi,2*rayonArrondi,arrondiHauteur+deltaVide], center = true, $fn=100);  
        
        translate([-rayonArrondi,rayonArrondi/2,0]) //vidage carrée bas
        translate([0,0,(arrondiHauteur+deltaVide)/2])
        translate([0,0,0])        
            cube(size=[2*rayonArrondi, rayonArrondi,arrondiHauteur+deltaVide], center = true, $fn=100);        
    }    
}
}//fin module arrondiBasDroit(){

module arrondiBasGauche(){
difference(){
    arrondiHauteur = hauteurCubeContenant-epaisseurCubeContenant;
    rayonArrondi = 0.5;
    union(){    
        //solide cylindre
        translate([0,0,arrondiHauteur/2])
        translate([-rayonArrondi,0,0])
        translate([0,0,0])
            cylinder (h = arrondiHauteur, r=rayonArrondi, center = true, $fn=100);
        

               
    }
    union(){
        //vide cylindrique du cylindre
        color([0,0,0.7])
        translate([0,0,(arrondiHauteur+deltaVide)/2])
        translate([-rayonArrondi,0,0])
        translate([0,0,0])
            cylinder (h = arrondiHauteur+deltaVide, r=rayonArrondi-epaisseurCubeContenant, center = true, $fn=100);
        //couper un angle droit
        
        translate([rayonArrondi/2,0,0]) //vidage carrée gauche
        translate([-rayonArrondi,0,(arrondiHauteur+deltaVide)/2])
        translate([0,0,0])        
            cube(size=[rayonArrondi,2*rayonArrondi,arrondiHauteur+deltaVide], center = true, $fn=100);  
        
        translate([-rayonArrondi,rayonArrondi/2,0]) //vidage carrée bas
        translate([0,0,(arrondiHauteur+deltaVide)/2])
        translate([0,0,0])        
            cube(size=[2*rayonArrondi, rayonArrondi,arrondiHauteur+deltaVide], center = true, $fn=100);        
    }    
}
}//fin module arrondiBasGauche(){

module arrondiHautGauche(){
difference(){
    arrondiHauteur = hauteurCubeContenant-epaisseurCubeContenant;
    rayonArrondi = 0.5;
    union(){    
        //solide cylindre
        translate([0,0,arrondiHauteur/2])
        translate([-rayonArrondi,0,0])
        translate([0,0,0])
            cylinder (h = arrondiHauteur, r=rayonArrondi, center = true, $fn=100);
        

               
    }
    union(){
        //vide cylindrique du cylindre
        color([0,0,0.7])
        translate([0,0,(arrondiHauteur+deltaVide)/2])
        translate([-rayonArrondi,0,0])
        translate([0,0,0])
            cylinder (h = arrondiHauteur+deltaVide, r=rayonArrondi-epaisseurCubeContenant, center = true, $fn=100);
        //couper un angle droit
        
        translate([rayonArrondi/2,0,0]) //vidage carrée gauche
        translate([-rayonArrondi,0,(arrondiHauteur+deltaVide)/2])
        translate([0,0,0])        
            cube(size=[rayonArrondi,2*rayonArrondi,arrondiHauteur+deltaVide], center = true, $fn=100);  
        
        translate([-rayonArrondi,-rayonArrondi/2,0]) //vidage carrée bas
        translate([0,0,(arrondiHauteur+deltaVide)/2])
        translate([0,0,0])        
            cube(size=[2*rayonArrondi, rayonArrondi,arrondiHauteur+deltaVide], center = true, $fn=100);        
    }    
}
}//fin module arrondiHautGauche(){


module troueHAUTCubiquePourCubeContenant(){
        //Partie vide ------
        translate([0,0,1.12])
        translate([0,(profondeurCubeContenant/2)-(profondeurCube/2)
            -profondeurTrouTransfo-2*epaisseurCubeContenant,0])
        translate([0,0,(hauteurCubeContenantVider+deltaVide)/2])
        color([1,0,1])
        cube(size = [largeurCubeContenantVider+(2*largeur4attachesPriseFemelle), profondeurCubeContenantVider,       
             hauteurCubeContenantVider+deltaVide+0.3], center = true, $fn=100);
}
module troueCubiquePourCubeContenant(){
        //Partie vide ------
        translate([0,(profondeurCubeContenant/2)-(profondeurCube/2)
            -profondeurTrouTransfo-2*epaisseurCubeContenant,0])
        translate([0,0,(hauteurCubeContenantVider+deltaVide)/2])
        color([1,0,1])
        cube(size = [largeurCubeContenantVider, profondeurCubeContenantVider,       
             hauteurCubeContenantVider+deltaVide], center = true, $fn=100);
}
module troueCubiquePourPriseFemelle(){
//vider la base cubique de la prise femelle ---------
//-------------------------------------------
    translate([0,0,(hauteurCubeContenantVider+deltaVide)/2])
        color("red")
        cube(size = [largeurCube, profondeurCube, hauteurCubeContenantVider+deltaVide], center = true, $fn=100);
    //vider les 4 attaches de la prise femelle
    //4attachesPriseFemelle();
    //vider le carré de troue de la prise femelle
    trouePriseFemelle();
}    
module trouePriseFemelle(){
largeurTroueCarre = 4.22;
hauteurTroueCarre = 2*(hauteurTrouRelay+epaisseurParoisTransfo)+deltaVide;    
cube(size = [largeurTroueCarre, largeurTroueCarre, hauteurTroueCarre], center = true, $fn=100);    
}

module 4attachesPriseFemelle(){
decalageAttacheBord = 0.41;
hauteur4attachesPriseFemelle = hauteurTrouRelay+epaisseurParoisTransfo+deltaVide;
profondeur4attachesPriseFemelle = 0.86;

//attache droite arrière
translate([0,-decalageAttacheBord,0])
translate([0,0,(hauteur4attachesPriseFemelle/2)])
translate([0,-(profondeur4attachesPriseFemelle/2),0])
translate([0,profondeurCube/2,0])
translate([(largeurCube/2)+(largeur4attachesPriseFemelle/2)-(deltaVide/2),0,0])
    cube(size = [largeur4attachesPriseFemelle+deltaVide, profondeur4attachesPriseFemelle, hauteur4attachesPriseFemelle], center = true, $fn=100);
//attache droite devant
translate([0,+decalageAttacheBord,0])
translate([0,0,(hauteur4attachesPriseFemelle/2)])
translate([0,+(profondeur4attachesPriseFemelle/2),0])
translate([0,-profondeurCube/2,0])
translate([(largeurCube/2)+(largeur4attachesPriseFemelle/2)-(deltaVide/2),0,0])
    cube(size = [largeur4attachesPriseFemelle+deltaVide, profondeur4attachesPriseFemelle, hauteur4attachesPriseFemelle], center = true, $fn=100);    
//attache gauche arrière
translate([0,-decalageAttacheBord,0])
translate([0,0,(hauteur4attachesPriseFemelle/2)])
translate([0,-(profondeur4attachesPriseFemelle/2),0])
translate([0,profondeurCube/2,0])
translate([-(largeurCube/2)-(largeur4attachesPriseFemelle/2)+(deltaVide/2),0,0])
    cube(size = [largeur4attachesPriseFemelle+deltaVide, profondeur4attachesPriseFemelle, hauteur4attachesPriseFemelle], center = true, $fn=100);
//attache gauche devant
translate([0,+decalageAttacheBord,0])
translate([0,0,(hauteur4attachesPriseFemelle/2)])
translate([0,+(profondeur4attachesPriseFemelle/2),0])
translate([0,-profondeurCube/2,0])
translate([-(largeurCube/2)-(largeur4attachesPriseFemelle/2)+(deltaVide/2),0,0])
    cube(size = [largeur4attachesPriseFemelle+deltaVide, profondeur4attachesPriseFemelle, hauteur4attachesPriseFemelle], center = true, $fn=100);    
}

    
