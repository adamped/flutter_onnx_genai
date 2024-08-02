//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <onnx_genai/onnx_gen_a_i.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) onnx_genai_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "OnnxGenAI");
  onnx_gen_a_i_register_with_registrar(onnx_genai_registrar);
}
