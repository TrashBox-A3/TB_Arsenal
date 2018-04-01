_dialog = createDialog "TB_dialog";
if (!_dialog) exitWith {systemChat "Error: Can't open 'CH Specialized Arsenal' dialog."};
disableSerialization;
_this call TB_fnc_updateDialog;