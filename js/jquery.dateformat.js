(function(a){var b=["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"],c=["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"],d=["January","February","March","April","May","June","July","August","September","October","November","December"],e=[];e.Jan="01",e.Feb="02",e.Mar="03",e.Apr="04",e.May="05",e.Jun="06",e.Jul="07",e.Aug="08",e.Sep="09",e.Oct="10",e.Nov="11",e.Dec="12",a.format=function(){function a(a){return b[parseInt(a,10)]||a}function f(a){var b=parseInt(a,10)-1;return c[b]||a}function g(a){var b=parseInt(a,10)-1;return d[b]||a}var h=function(a){return e[a]||a},i=function(a){var b=a,c="";if(b.indexOf(".")!==-1){var d=b.split(".");b=d[0],c=d[1]}var e=b.split(":");return e.length===3?(hour=e[0],minute=e[1],second=e[2],{time:b,hour:hour,minute:minute,second:second,millis:c}):{time:"",hour:"",minute:"",second:"",millis:""}};return{date:function(b,c){try{var d=null,e=null,j=null,k=null,l=null,m=null;if(typeof b=="number")return this.date(new Date(b),c);if(typeof b.getFullYear=="function")e=b.getFullYear(),j=b.getMonth()+1,k=b.getDate(),l=b.getDay(),m=i(b.toTimeString());else if(b.search(/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.?\d{0,3}[-+]?\d{2}:?\d{2}/)!=-1){var n=b.split(/[T\+-]/);e=n[0],j=n[1],k=n[2],m=i(n[3].split(".")[0]),d=new Date(e,j-1,k),l=d.getDay()}else{var n=b.split(" ");switch(n.length){case 6:e=n[5],j=h(n[1]),k=n[2],m=i(n[3]),d=new Date(e,j-1,k),l=d.getDay();break;case 2:var o=n[0].split("-");e=o[0],j=o[1],k=o[2],m=i(n[1]),d=new Date(e,j-1,k),l=d.getDay();break;case 7:case 9:case 10:e=n[3],j=h(n[1]),k=n[2],m=i(n[4]),d=new Date(e,j-1,k),l=d.getDay();break;case 1:var o=n[0].split("");e=o[0]+o[1]+o[2]+o[3],j=o[5]+o[6],k=o[8]+o[9],m=i(o[13]+o[14]+o[15]+o[16]+o[17]+o[18]+o[19]+o[20]),d=new Date(e,j-1,k),l=d.getDay();break;default:return b}}var p="",q="",r="";for(var s=0;s<c.length;s++){var t=c.charAt(s);p+=t,r="";switch(p){case"ddd":q+=a(l),p="";break;case"dd":if(c.charAt(s+1)=="d")break;String(k).length===1&&(k="0"+k),q+=k,p="";break;case"d":if(c.charAt(s+1)=="d")break;q+=parseInt(k,10),p="";break;case"MMMM":q+=g(j),p="";break;case"MMM":if(c.charAt(s+1)==="M")break;q+=f(j),p="";break;case"MM":if(c.charAt(s+1)=="M")break;String(j).length===1&&(j="0"+j),q+=j,p="";break;case"M":if(c.charAt(s+1)=="M")break;q+=parseInt(j,10),p="";break;case"yyyy":q+=e,p="";break;case"yy":if(c.charAt(s+1)=="y"&&c.charAt(s+2)=="y")break;q+=String(e).slice(-2),p="";break;case"HH":q+=m.hour,p="";break;case"hh":var u=m.hour==0?12:m.hour<13?m.hour:m.hour-12;u=String(u).length==1?"0"+u:u,q+=u,p="";break;case"h":if(c.charAt(s+1)=="h")break;var u=m.hour==0?12:m.hour<13?m.hour:m.hour-12;q+=parseInt(u,10),p="";break;case"mm":q+=m.minute,p="";break;case"ss":q+=m.second.substring(0,2),p="";break;case"SSS":q+=m.millis.substring(0,3),p="";break;case"a":q+=m.hour>=12?"PM":"AM",p="";break;case" ":q+=t,p="";break;case"/":q+=t,p="";break;case":":q+=t,p="";break;default:p.length===2&&p.indexOf("y")!==0&&p!="SS"?(q+=p.substring(0,1),p=p.substring(1,2)):p.length===3&&p.indexOf("yyy")===-1?p="":r=p}}return q+=r,q}catch(v){return console.log(v),b}}}}()})(jQuery)