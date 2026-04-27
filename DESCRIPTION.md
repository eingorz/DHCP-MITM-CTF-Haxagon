# DHCP Meltdown: Dunder Mifflin

Dunder Mifflin Scranton má problém. Dwight Schrute si vzal do hlavy, že lokální síť je přeplněná a IP adresami se zbytečně plýtvá. *„Proč má mít každý nedůležitý přístroj vlastní adresu, když jich na pobočce potřebujeme sotva hrstku?"* prohlásil a celou síťovou infrastrukturu od podlahy „vylepšil". Výsledkem je, že IP adresy se staly totálně nedostatkovým zbožím a dochází k nim rychleji než k papíru ve skladu.

A aby ukázal, že má moderní technologie kompletně v malíku, zavedl si Dwight na svém stroji ještě speciální automatický systém. Každou chvíli si přes síť posílá nějaká data — prý jde o nesmírně důležité tajné zálohy a systémové aktualizace. *„Síť je bezpečná, nikdo se nemá šanci do mého geniálního přenosu nabourat,"* chvástá se.

Jako Jim Halpert vidíš naprosto jasnou příležitost k pranku:

1. Prý jsou adresy nedostatkové zboží a síťová pravidla neprůstřelná? Co kdyby se ta hrstka zbývajících adres najednou záhadně vypařila? Třeba by pak Dwightův stroj v zoufalství hledal nového správce sítě... a našel by tebe.
2. Pokud by se podařilo přesvědčit Dwightův stroj, aby veškerou svou domněle bezpečnou komunikaci svěřil tvému zařízení, nešlo by z těch dat náhodou něco přečíst?
3. A když už máš absolutní kontrolu nad tím, co přesně Dwightovi po síti teče... věří svým automatickým datům natolik, že by spolkl i to, kdybys mu obsah těch obíhajících zpráv rovnou upravil přímo pod rukama?

> **Útoky veď na rozhraní `eth1`.**

---

<if ip="false">

**Před připojením na úlohu je nutné, aby byla spuštěná.**

</if>
<if ip>

**Připojení přes SSH:** `ssh student@<ip>` (heslo: `goldtitle8`)

</if>
