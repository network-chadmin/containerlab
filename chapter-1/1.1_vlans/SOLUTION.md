## Solution Configs

## Final configuration

hostname shr-a1-asw1
!
vlan 10
 name ACCOUNTING
!
vlan 20
 name SALES
!
interface Ethernet1
 description Bob-Accounting
 switchport mode access
 switchport access vlan 10
 no shutdown
!
interface Ethernet2
 description Linda-Accounting
 switchport mode access
 switchport access vlan 10
 no shutdown
!
interface Ethernet3
 description Alice-Sales
 switchport mode access
 switchport access vlan 20
 no shutdown
