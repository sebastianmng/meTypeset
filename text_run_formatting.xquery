xquery version "1.0";
declare namespace w="http://schemas.openxmlformats.org/wordprocessingml/2006/main";



     declare function local:ml-update-document-xml($doc as element(w:document)) as element(w:document)

     {

       local:dispatch($doc)

     };



     declare function local:passthru($x as node()) as node()

     {

       for $i in $x/node() return local:dispatch($i)

     };



     declare function local:dispatch ($x as node()) as node()

     {



      typeswitch ($x)

       case element(w:p) return local:mergeruns($x)

       default return (

         element{fn:name($x)} {$x/@*,local:passthru($x)}

       )

     };



     declare function local:mergeruns($p as element(w:p)) as element(w:p)

     {

       let $pPrvals := if(fn:exists($p/w:pPr)) then $p/w:pPr else ()

       return element w:p{ $pPrvals, local:map($p/w:r[1]) }



     };



     declare function local:descend($r as element(w:r)?, $rToCheck as element(w:rPr)?) as element(w:r)*

     {

       if(fn:empty($r)) then ()

       else if(fn:deep-equal($r/w:rPr,$rToCheck)) then

        ($r, local:descend($r/following-sibling::w:r[1], $rToCheck))

       else ()

     };



     declare function local:map($r as element(w:r)?) as element(w:r)

     {

       if (fn:empty($r)) then ()

       else

        let $rToCheck := $r/w:rPr



       let $matches := local:descend($r/following-sibling::w:r[1], $rToCheck)

       let $count := fn:count($matches)



       let $this := if ($count) then

                   (element w:r{ $rToCheck,

                         element w:t { fn:string-join(($r/w:t, $matches/w:t),"") } })

                 else $r



       return  ($this, local:map( if($count) then ($r/following-sibling::w:r[1 + $count])  else $r/following-sibling::w:r[1]))

     };
     
declare variable $toparse := doc("/Users/sebastianmunoznajar/Documents/PKP/coactionDocx/19159-66544-3-RV-1.docx/word/document.xml");

<dispatch>{local:dispatch($toparse)}</dispatch>