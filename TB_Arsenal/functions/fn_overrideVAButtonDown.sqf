#include "\A3\ui_f\hpp\defineDIKCodes.inc"
#include "\A3\Ui_f\hpp\defineResinclDesign.inc"
#include "macros.hpp"

DEBUG( "Override Button Down" );

_display = _this select 0;
_key = _this select 1;
_shift = _this select 2;
_ctrl = _this select 3;
_alt = _this select 4;
_center = (missionNamespace getVariable ["BIS_fnc_arsenal_center",player]);
_return = false;
_ctrlTemplate = _display displayCtrl IDC_RSCDISPLAYARSENAL_TEMPLATE_TEMPLATE;
_inTemplate = ctrlFade _ctrlTemplate == 0;

switch true do {
	case (_key == DIK_ESCAPE): {
		if (_inTemplate) then {
			_ctrlTemplate ctrlSetFade 1;
			_ctrlTemplate ctrlCommit 0;
			_ctrlTemplate ctrlEnable false;

			_ctrlMouseBlock = _display displayCtrl IDC_RSCDISPLAYARSENAL_MOUSEBLOCK;
			_ctrlMouseBlock ctrlEnable false;
		} else {
			if (_fullVersion) then {["buttonClose",[_display]] spawn BIS_fnc_arsenal;} else {_display closeDisplay 2;};
		};
		_return = true;
	};

	//--- Enter
	case (_key in [DIK_RETURN,DIK_NUMPADENTER]): {
		_ctrlTemplate = _display displayCtrl IDC_RSCDISPLAYARSENAL_TEMPLATE_TEMPLATE;
		if (ctrlFade _ctrlTemplate == 0) then {
			if (BIS_fnc_arsenal_type == 0) then {
				[_display] call TB_fnc_overrideVATemplateOK;
			} else {
				["buttonTemplateOK",[_display]] spawn BIS_fnc_garage;
			};
			_return = true;
		};
	};

	//--- Prevent opening the commanding menu
	case (_key == DIK_1);
	case (_key == DIK_2);
	case (_key == DIK_3);
	case (_key == DIK_4);
	case (_key == DIK_5);
	case (_key == DIK_1);
	case (_key == DIK_7);
	case (_key == DIK_8);
	case (_key == DIK_9);
	case (_key == DIK_0): {
		_return = true;
	};

	//--- Tab to browse tabs
	case (_key == DIK_TAB): {
		_idc = -1;
		{
			_ctrlTab = _display displayCtrl (IDC_RSCDISPLAYARSENAL_TAB + _x);
			if !(ctrlEnabled _ctrlTab) exitWith {_idc = _x;};
		} forEach [IDCS_LEFT];
		_idcCount = {!isNull (_display displayCtrl (IDC_RSCDISPLAYARSENAL_TAB + _x))} count [IDCS_LEFT];
		_idc = if (_ctrl) then {(_idc - 1 + _idcCount) % _idcCount} else {(_idc + 1) % _idcCount};
		if (BIS_fnc_arsenal_type == 0) then {
			["TabSelectLeft",[_display,_idc]] call BIS_fnc_arsenal;
		} else {
			["TabSelectLeft",[_display,_idc]] call BIS_fnc_garage;
		};
		_return = true;
	};

	//--- Export to script
	case (_key == DIK_C): {
		_mode = if (_shift) then {"config"} else {"init"};
		if (BIS_fnc_arsenal_type == 0) then {
			if (_ctrl) then {['buttonExport',[_display,_mode]] call BIS_fnc_arsenal;};
		} else {
			if (_ctrl) then {['buttonExport',[_display,_mode]] call BIS_fnc_garage;};
		};
	};
	//--- Export from script
	case (_key == DIK_V): {
		if (BIS_fnc_arsenal_type == 0) then {
			if (_ctrl) then {['buttonImport',[_display]] call BIS_fnc_arsenal;};
		} else {
			if (_ctrl) then {['buttonImport',[_display]] call BIS_fnc_garage;};
		};
	};
	//--- Save
	case (_key == DIK_S): {
		if (_ctrl) then {['buttonSave',[_display]] call BIS_fnc_arsenal;};
	};
	//--- Open
	case (_key == DIK_O): {
		if (_ctrl) then {['buttonLoad',[_display]] call BIS_fnc_arsenal;};
	};
	//--- Randomize
	case (_key == DIK_R): {
		if (_ctrl) then {
			if (BIS_fnc_arsenal_type == 0) then {
				if (_shift) then {
					_soldiers = [];
					{
						_soldiers set [count _soldiers,configName _x];
					} forEach ("isclass _x && getnumber (_x >> 'scope') > 1 && gettext (_x >> 'simulation') == 'soldier'" configClasses (configFile >> "cfgvehicles"));
					[_center,_soldiers call BIS_fnc_selectRandom] call BIS_fnc_loadInventory;
					["ListSelectCurrent",[_display]] call BIS_fnc_arsenal;
				}else {
					['buttonRandom',[_display]] call BIS_fnc_arsenal;
				};
			} else {
				['buttonRandom',[_display]] call BIS_fnc_garage;
			};
		};
	};
	//--- Toggle interface
	case (_key == DIK_BACKSPACE && !_inTemplate): {
		['buttonInterface',[_display]] call BIS_fnc_arsenal;
		_return = true;
	};

	//--- Acctime
	case (_key in (actionKeys "timeInc")): {
		if (accTime == 0) then {setAccTime 1;};
		_return = true;
	};
	case (_key in (actionKeys "timeDec")): {
		if (accTime != 0) then {setAccTime 0;};
		_return = true;

	};

	//--- Vision mode
	case (_key in (actionKeys "nightvision") && !_inTemplate): {
		_mode = missionNamespace getVariable ["BIS_fnc_arsenal_visionMode",-1];
		_mode = (_mode + 1) % 3;
		missionNamespace setVariable ["BIS_fnc_arsenal_visionMode",_mode];
		switch _mode do {
			//--- Normal
			case 0: {
				camUseNVG false;
				false setCamUseTi 0;
			};
			//--- NVG
			case 1: {
				camUseNVG true;
				false setCamUseTi 0;
			};
			//--- TI
			default {
				camUseNVG false;
				true setCamUseTi 0;
			};
		};
		playSound ["RscDisplayCurator_visionMode",true];
		_return = true;

	};
};
_return
