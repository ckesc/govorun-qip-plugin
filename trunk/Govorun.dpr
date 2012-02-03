library Govorun;

{%DotNetAssemblyCompiler 'bass.dll'}

uses
  u_qip_plugin in 'u_qip_plugin.pas',
  u_baseplugin in '..\SDK\SDK_1_11_0\SDK\u_baseplugin.pas',
  u_common in '..\SDK\SDK_1_11_0\SDK\u_common.pas',
  u_lang_ids in '..\SDK\SDK_1_11_0\SDK\u_lang_ids.pas',
  u_plugin_msg in '..\SDK\SDK_1_11_0\SDK\u_plugin_msg.pas',
  u_PopupEx in '..\SDK\SDK_1_11_0\SDK\u_PopupEx.pas',
  u_qip_msg in '..\SDK\SDK_1_11_0\SDK\u_qip_msg.pas',
  u_plugin_info in '..\SDK\SDK_1_11_0\SDK\u_plugin_info.pas',
  unitMessage in 'unitMessage.pas';

{$R *.res}

{***********************************************************}
function CreateInfiumPLUGIN(PluginService: IQIPPluginService): IQIPPlugin; stdcall;
begin
  Result := TQipPlugin.Create(PluginService);
end;

exports
  CreateInfiumPLUGIN name 'CreateInfiumPLUGIN';

end.
