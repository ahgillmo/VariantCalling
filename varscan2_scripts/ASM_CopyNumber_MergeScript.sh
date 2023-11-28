#!/bin/bash
filename=$1

less $filename |
awk 'BEGIN{
          chr=start=end=num=cn=0
         } {
             #print "xx\t"$0; 
             if(NR==1) {
                          chr=$1; 
                          start=$2; 
                          end=$3; 
                          num=$4;
                          cn=$5
              } else {
                          if(chr!=$1){
                                   print chr"\t"start"\t"end"\t"num"\t"cn; 
                                   chr=$1; 
                                   start=$2; 
                                   end=$3; 
                                   num=$4; 
                                   cn=$5;
                          }
                          if((chr==$1) && ($4<15)) {
                                       end=$3; 
                                       num=num+$4;
                                       #print "adding short seg\n";
                           } else {
                                        if ((chr==$1) && ($4>=14) && ( (($5-cn)<0.25) || (($5+cn)<0.25) || (($5+cn)<(-0.25)) || (($5-cn)<(-0.25)) )) {
                                                    end=$3; 
                                                    cn=((cn*num)+($4*$5))/(num+$4); 
#                                                  cn=x; 
                                                    num=num+$4; 
#                                                  num=y;
                                                    #print "adding LONG seg\n";
                                      } else {
                                                    print chr"\t"start"\t"end"\t"num"\t"cn; 
                                                    chr=$1; 
                                                    start=$2; 
                                                    end=$3; 
                                                    num=$4; 
                                                    cn=$5;
                                       }
                          }  
             }
}
END{
             print chr"\t"start"\t"end"\t"num"\t"cn; 
}' | 

awk 'BEGIN{
          chr=start=end=num=cn=0
         } {
             #print "xx\t"$0; 
             if(NR==1) {
                          chr=$1; 
                          start=$2; 
                          end=$3; 
                          num=$4;
                          cn=$5
              } else {
                          if(chr!=$1){
                                   print chr"\t"start"\t"end"\t"num"\t"cn; 
                                   chr=$1; 
                                   start=$2; 
                                   end=$3; 
                                   num=$4; 
                                   cn=$5;
                          }
                          if((chr==$1) && ($4<15)) {
                                       end=$3; 
                                       num=num+$4;
                                       #print "adding short seg\n";
                           } else {
                                        if ((chr==$1) && ($4>=14) && ( (($5-cn)<0.25) || (($5+cn)<0.25) || (($5+cn)<(-0.25)) || (($5-cn)<(-0.25)) )) {
                                                    end=$3; 
                                                    cn=((cn*num)+($4*$5))/(num+$4); 
#                                                  cn=x; 
                                                    num=num+$4; 
#                                                  num=y;
                                                    #print "adding LONG seg\n";
                                      } else {
                                                    print chr"\t"start"\t"end"\t"num"\t"cn; 
                                                    chr=$1; 
                                                    start=$2; 
                                                    end=$3; 
                                                    num=$4; 
                                                    cn=$5;
                                       }
                          }  
             }
}
END{
             print chr"\t"start"\t"end"\t"num"\t"cn; 
}'
