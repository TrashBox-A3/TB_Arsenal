
#include "\A3\Ui_f\hpp\defineResinclDesign.inc"
#include "macros.hpp"

if ( hasInterface ) then {
	
	{
		uiNamespace setVariable[ _x, missionNamespace getVariable _x ];
	}forEach [
		"TB_fnc_overrideVAButtonDown", 
		"TB_fnc_overrideVATemplateOK",
		"TB_fnc_loadInventory_whiteList"
	];

	DEBUG( "Adding arsenalOpened SEH" );

	[ missionNamespace, "arsenalOpened", {
	    disableSerialization;
	    _display = _this select 0;
		
		DEBUG( "arsenalOpened SEH called" );
		
		waitUntil { !isNil "BIS_fnc_arsenal_target" };

		DEBUG( "SEH target done" );

		_center = BIS_fnc_arsenal_center;
		_cargo = BIS_fnc_arsenal_cargo;
		
		_msg = format[ "SEH: Center: %1, Cargo: %2", _center, _cargo ];
		DEBUG( _msg );

		_virtualItemCargo =
			(missionNamespace call BIS_fnc_getVirtualItemCargo) +
			(_cargo call BIS_fnc_getVirtualItemCargo) +
			items _center +
			assignedItems _center +
			primaryWeaponItems _center +
			secondaryWeaponItems _center +
			handgunItems _center +
			[uniform _center,vest _center,headgear _center,goggles _center];
			
		_virtualWeaponCargo = [];
		{
			_weapon = _x call BIS_fnc_baseWeapon;
			_virtualWeaponCargo set [count _virtualWeaponCargo,_weapon];
			{
				private ["_item"];
				_item = getText (_x >> "item");
				if !(_item in _virtualItemCargo) then {_virtualItemCargo set [count _virtualItemCargo,_item];};
			} forEach ((configFile >> "cfgweapons" >> _x >> "linkeditems") call BIS_fnc_returnChildren);
		} forEach ((missionNamespace call BIS_fnc_getVirtualWeaponCargo) + (_cargo call BIS_fnc_getVirtualWeaponCargo) + weapons _center + [binocular _center]);
			
		_virtualMagazineCargo = (missionNamespace call BIS_fnc_getVirtualMagazineCargo) + (_cargo call BIS_fnc_getVirtualMagazineCargo) + magazines _center;
		_virtualBackpackCargo = (missionNamespace call BIS_fnc_getVirtualBackpackCargo) + (_cargo call BIS_fnc_getVirtualBackpackCargo) + [backpack _center];
		
		_virtualCargo = [];
		{
			{
				_nul = _virtualCargo pushBack ( toLower _x );
			}forEach _x;
		}forEach [
			_virtualItemCargo,
			_virtualWeaponCargo,
			_virtualMagazineCargo,
			_virtualBackpackCargo
		];

		uiNamespace setVariable [ "LARs_override_virtualCargo", _virtualCargo ];
		
		_msg = format[ "SEH: VCargo: %1", uiNamespace getVariable "LARs_override_virtualCargo" ];
		DEBUG( _msg );

		//VA template button OK
		_ctrlTemplateButtonOK = _display displayCtrl IDC_RSCDISPLAYARSENAL_TEMPLATE_BUTTONOK;
		_ctrlTemplateButtonOK ctrlRemoveAllEventHandlers "buttonclick";
		_ctrlTemplateButtonOK ctrlAddEventHandler ["buttonclick","with uinamespace do {[ctrlparent (_this select 0)] call TB_fnc_overrideVATemplateOK;};"];
		
		_msg = format[ "SEH: OK: %1", _ctrlTemplateButtonOK ];
		DEBUG( _msg );

		//VA template listbox DblClick
		_ctrlTemplateValue = _display displayCtrl IDC_RSCDISPLAYARSENAL_TEMPLATE_VALUENAME;
		_ctrlTemplateValue ctrlRemoveAllEventHandlers "lbdblclick";
		_ctrlTemplateValue ctrlAddEventHandler ["lbdblclick","with uinamespace do {[ctrlparent (_this select 0)] call TB_fnc_overrideVATemplateOK;};"];
		
		_msg = format[ "SEH: OK: %1", _ctrlTemplateValue ];
		DEBUG( _msg );

		//VA button down, needed to override ENTER on template listbox
		_display displayAddEventHandler ["keydown","with (uinamespace) do {_this call TB_fnc_overrideVAButtonDown;};"];
		
	} ] call BIS_fnc_addScriptedEventHandler;
};