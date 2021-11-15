# VLANS - Chapter-3 Notes

---

## VLAN Show Commands

**Editing Required**

Voice VLAN Verification Example `show interface fa0/18 switchport`
the show interfaces interface-id switchport and the show interfaces vlan vlan-id command. For example, the show interfaces fa0/18 switchport command can be used to confirm that the FastEthernet 0/18 port has been correctly assigned to data and voice VLANs.
The show vlan summary command displays the count of all configured VLANs.

## Verify VLAN Information

The `show vlan` command can also be used with options. The complete syntax is `show vlan [brief | id vlan-id | name vlan-name | summary]`.

`show vlan name student`

Task	Command Option
Display VLAN name, status, and its ports one VLAN per line.	
brief
Display information about the identified VLAN ID number. For vlan-id, the range is 1 to 4094.	
id vlan-id
Display information about the identified VLAN name. The vlan-name is an ASCII string from 1 to 32 characters.	
name vlan-name
Display VLAN summary information.	
summary

The `show vlan summary` command displays the count of all configured VLANs.

```
S1# show vlan summary
Number of existing VLANs              : 7
Number of existing VTP VLANs          : 7
Number of existing extended VLANS     : 0
```
Other useful commands are the show interfaces interface-id switchport and the show interfaces vlan vlan-id command. For example, the show interfaces fa0/18 switchport command can be used to confirm that the FastEthernet 0/18 port has been correctly assigned to data and voice VLANs.
```
S1# show interface fa0/18 switchport
Name: Fa0/18
Switchport: Enabled
Administrative Mode: static access
Operational Mode: static access
Administrative Trunking Encapsulation: dot1q
Operational Trunking Encapsulation: native
Negotiation of Trunking: Off
Access Mode VLAN: 20 (student) 
Trunking Native Mode VLAN: 1 (default)
Voice VLAN: 150
Administrative private-vlan host-association: none
(Output omitted)
```
---

# VLAN Set-Up

## VLAN Creation Commands

|Task	|IOS Command|
|-------|-----------|
|Enter global configuration mode.	|Switch# configure terminal|
|Create a VLAN with a valid ID number.	|Switch(config)# vlan vlan-id|
|Specify a unique name to identify the VLAN.	|Switch(config-vlan)# name vlan-name|
|Return to the privileged EXEC mode.	|Switch(config-vlan)# end|

```
S1# configure terminal
S1(config)# vlan 20
S1(config-vlan)# name student
S1(config-vlan)# end
```
a series of VLAN IDs can be entered separated: `vlan 100,102,105-107`

## VLAN Port Assignment Commands

The `switchport mode access` command is strongly recommended as a security best practice. The interface changes to strictly access mode. Access mode indicates that the port belongs to a single VLAN and will not negotiate to become a trunk link.

|Task	|IOS Command|
|-------|-----------|
|Enter global configuration mode.	|Switch# configure terminal|
|Enter interface configuration mode.	|Switch(config)# interface interface-id|
|Set the port to access mode.	|Switch(config-if)# switchport mode access|
|Assign the port to a VLAN.	|Switch(config-if)# switchport access vlan vlan-id|
|Return to the privileged EXEC mode.	|Switch(config-if)# end|

Note: Use the interface range command to simultaneously configure multiple interfaces.
### VLAN Port Assignment Example
```
S1# configure terminal
S1(config)# interface fa0/6
S1(config-if)# switchport mode access
S1(config-if)# switchport access vlan 20
S1(config-if)# end
```

## Data and Voice VLAN

Use the `switchport voice vlan vlan-id` interface configuration command to assign a voice VLAN to a port.

Use the `mls qos trust [cos | device cisco-phone | dscp | ip-precedence]` interface configuration command to set the trusted state of an interface, and to indicate which fields of the packet are used to classify traffic.

```
S3(config)# vlan 20
S3(config-vlan)# name student
S3(config-vlan)# vlan 150
S3(config-vlan)# name VOICE
S3(config-vlan)# exit
S3(config)# interface fa0/18
S3(config-if)# switchport mode access
S3(config-if)# switchport access vlan 20
S3(config-if)# mls qos trust cos
S3(config-if)# switchport voice vlan 150
S3(config-if)# end
S3#
```
The switchport access vlan command forces the creation of a VLAN if it does not already exist on the switch. 

## Change VLAN Port Membership

To correct a port that has been incorrectly assigned to a VLAN, enter the `switchport access vlan vlan-id` interface configuration command with the correct VLAN ID.
e.g if FA0/18 was incorrectly configured to be on the default VLAN 1 instead of VLAN 20, change the port to VLAN 20, simply enter `switchport access vlan 20`.

To change the membership of a port back to the default VLAN 1, use the `no switchport access vlan` interface config command.

Confirm the change with `show vlan brief` command.

```
S1(config)# interface fa0/18
S1(config-if)# no switchport access vlan
S1(config-if)# end
S1#
S1# show vlan brief
VLAN Name                 Status    Ports
---- ------------------ --------- -------------------------------
1    default            active    Fa0/1, Fa0/2, Fa0/3, Fa0/4
                                  Fa0/5, Fa0/6, Fa0/7, Fa0/8
                                  Fa0/9, Fa0/10, Fa0/11, Fa0/12
                                  Fa0/13, Fa0/14, Fa0/15, Fa0/16
                                  Fa0/17, Fa0/18, Fa0/19, Fa0/20
                                  Fa0/21, Fa0/22, Fa0/23, Fa0/24
                                  Gi0/1, Gi0/2
20   student            active    
1002 fddi-default       act/unsup 
1003 token-ring-default act/unsup 
1004 fddinet-default    act/unsup 
1005 trnet-default      act/unsup
```

The `show interfaces f0/18 switchport` output can also be used to verify that the access VLAN for interface F0/18 has been reset to VLAN 1 as shown in the output.

```
S1# show interfaces fa0/18 switchport
Name: Fa0/18
Switchport: Enabled
Administrative Mode: static access
Operational Mode: static access
Administrative Trunking Encapsulation: negotiate
Operational Trunking Encapsulation: native
Negotiation of Trunking: Off
Access Mode VLAN: 1 (default)
Trunking Native Mode VLAN: 1 (default)
```
## Delete VLANs
**Editing Required**

To remove the an active vlan from a port: 
```
S1#configure terminal
S1(config)#interface fa0/18
S1(config-if)#no switchport access vlan
```
Assign to F0/11
```
S1(config-if)#interface fa0/11
S1(config-if)#switchport mode access
S1(config-if)#switchport access vlan 20
S1(config-if)#end
```

The `no vlan vlan-id` global configuration mode command is used to remove a VLAN from the switch vlan.dat file.

**Caution: Before deleting** a VLAN, reassign all member ports to a different VLAN first. Any ports that are not moved to an active VLAN are unable to communicate with other hosts after the VLAN is deleted and until they are assigned to an active VLAN. 

The entire vlan.dat file can be deleted using the delete flash:vlan.dat privileged EXEC mode command. The abbreviated command version (delete vlan.dat) can be used if the vlan.dat file has not been moved from its default location. After issuing this command and reloading the switch, any previously configured VLANs are no longer present. This effectively places the switch into its factory default condition with regard to VLAN configurations.

Note: To restore a Catalyst switch to its factory default condition, unplug all cables except the console and power cable from the switch. Then enter the erase startup-config privileged EXEC mode command followed by the delete vlan.dat command.

---

# Trunk Configuration Commands

Now that you have configured and verified VLANs, it is time to configure and verify VLAN trunks. A VLAN trunk is a Layer 2 link between two switches that carries traffic for all VLANs (unless the allowed VLAN list is restricted manually or dynamically).

To enable trunk links, configure the interconnecting ports with the set of interface configuration commands shown in the table.

**Table  to edit** 
Task	IOS Command
Enter global configuration mode.	
Switch# configure terminal
Enter interface configuration mode.	
Switch(config)# interface interface-id
Set the port to permanent trunking mode.	
Switch(config-if)# switchport mode trunk
Sets the native VLAN to something other than VLAN 1.	
Switch(config-if)# switchport trunk native vlan vlan-id
Specify the list of VLANs to be allowed on the trunk link.	
Switch(config-if)# switchport trunk allowed vlan vlan-list
Return to the privileged EXEC mode.	
Switch(config-if)# end

Always configure both ends of a trunk link with the same native VLAN.
Configuration is verified with the `show interfaces interface-ID switchport` command and the `show interface trunk` command.

```
S1(config)# interface fastEthernet 0/1
S1(config-if)# switchport mode trunk
S1(config-if)# switchport trunk native vlan 99
S1(config-if)# switchport trunk allowed vlan 10,20,30,99
S1(config-if)# end
S1# show interfaces fa0/1 switchport
Name: Fa0/1
Switchport: Enabled
Administrative Mode: trunk
Operational Mode: trunk
Administrative Trunking Encapsulation: dot1q
Operational Trunking Encapsulation: dot1q
Negotiation of Trunking: On
Access Mode VLAN: 1 (default)
Trunking Native Mode VLAN: 99 (VLAN0099)
Administrative Native VLAN tagging: enabled
Voice VLAN: none
Administrative private-vlan host-association: none 
Administrative private-vlan mapping: none 
Administrative private-vlan trunk native VLAN: none
Administrative private-vlan trunk Native VLAN tagging: enabled
Administrative private-vlan trunk encapsulation: dot1q
Administrative private-vlan trunk normal VLANs: none
Administrative private-vlan trunk associations: none
Administrative private-vlan trunk mappings: none
Operational private-vlan: none
Trunking VLANs Enabled: ALL
Pruning VLANs Enabled: 2-1001
(output omitted)
```
## Reset the Trunk to Its Default State
Use the `no switchport trunk allowed vlan` and the `no switchport trunk native vlan` commands to remove the allowed VLANs and reset the native VLAN of the trunk. When it is reset to the default state, the trunk allows all VLANs and uses VLAN 1 as the native VLAN

```
S1(config)# interface fa0/1
S1(config-if)# no switchport trunk allowed vlan
S1(config-if)# no switchport trunk native vlan
S1(config-if)# end
S1# show interfaces fa0/1 switchport
```
The `show interfaces f0/1 switchport` command reveals that the F0/1 interface is now in **static access mode**.

---

# Dynamic Trunking Protocol (DTP)

To enable trunking from a Cisco switch to a device that does not support DTP, use the `switchport mode trunk` and `switchport nonegotiate` interface configuration mode commands. This causes the interface to become a trunk, but it will not generate DTP frames.

```
S1(config-if)# switchport mode trunk
S1(config-if)# switchport nonegotiate
```

To re-enable dynamic trunking protocol use the `switchport mode dynamic auto` command.

```
S1(config-if)# switchport mode dynamic auto
```
Switchport mode trunk + switchport nonegotiate will prevent ports changing from trunk mode.
If the connecting ports are set to dynamic auto, they will not negotiate a trunk and will stay in the access mode state, creating an inactive trunk link.

## Negotiated Interface Modes

`Switch(config-if)# switchport mode { access | dynamic { auto | desirable } | trunk }`


|Option|	Description|
|------|---------------|
|access|Puts the interface (access port) into permanent nontrunking mode and negotiates to convert the link into a nontrunk link. The interface becomes a nontrunk interface, regardless of whether the neighboring interface is a trunk interface.|
|dynamic auto|Makes the interface able to convert the link to a trunk link. The interface becomes a trunk interface if the neighboring interface is set to trunk or desirable mode. The default switchport mode for all Ethernet interfaces is dynamic auto.|
|dynamic desirable|Makes the interface actively attempt to convert the link to a trunk link.The interface becomes a trunk interface if the neighboring interface is set to trunk, desirable, or dynamic auto mode.|
|trunk| Puts the interface into permanent trunking mode and negotiates to convert the neighboring link into a trunk link. The interface becomes a trunk interface even if the neighboring interface is not a trunk interface.|


## Results of a DTP Configuration

| |Dynamic Auto| Dynamic Desirable| Trunk| Access|
|-|------------|------------------|------|-------|
|Dynamic Auto| Access| Trunk| Trunk| Access|
|Dynamic Desirable| Trunk| Trunk| Trunk| Access| 
|Trunk |Trunk| Trunk| Trunk| Limited connectivity| 
|Access |Access| Access| Limited connectivity| Access

## Verify DTP Mode
The default DTP mode is dependent on the Cisco IOS Software version and on the platform. To determine the current DTP mode, issue the `show dtp interface` command as shown in the output.

```
S1# show dtp interface fa0/1
```

Note: A general best practice is to set the interface to trunk and nonegotiate when a trunk link is required.
