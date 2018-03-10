#include "ElasticOrange.hpp"

extern "C" void dsp(float time, float in1, float in2, float in3, float in4, float* out1, float* out2, float *out3, float* out4);

struct Evaluator : Module {
	enum ParamIds {
		NUM_PARAMS
	};
	enum InputIds {
		INPUT_1,
		INPUT_2,
		INPUT_3,
		INPUT_4,
		NUM_INPUTS
	};
	enum OutputIds {
		OUTPUT_1,
		OUTPUT_2,
		OUTPUT_3,
		OUTPUT_4,
		NUM_OUTPUTS
	};
	enum LightIds {
		NUM_LIGHTS
	};

        bool chickenInit = false;

	Evaluator() : Module(NUM_PARAMS, NUM_INPUTS, NUM_OUTPUTS, NUM_LIGHTS) {
        }
	void step() override;

	// For more advanced Module features, read Rack's engine.hpp header file
	// - toJson, fromJson: serialization of internal data
	// - onSampleRateChange: event triggered by a change of sample rate
	// - onReset, onRandomize, onCreate, onDelete: implements special behavior when user clicks these from the context menu
};


void Evaluator::step() {
    // We need to initialize chicken in the thread we are using it in.
    if (!chickenInit) {
        C_word result;
        // TODO are these good enough?
        // Use 16mb heap, 64k stack and symbols.
        CHICKEN_initialize(16*1024*1024, 65535, 65535, (void*)C_toplevel);
        CHICKEN_run((void*)C_toplevel);
        CHICKEN_eval_string((char*)"(start-nrepl)", &result);
        chickenInit = true;
    }

    float deltaTime = engineGetSampleTime();
    dsp(deltaTime, inputs[0].value, inputs[1].value, inputs[2].value, inputs[3].value,
            &(outputs[0].value), &(outputs[1].value), &(outputs[2].value), &(outputs[3].value));

    CHICKEN_yield();
}


struct EvaluatorWidget : ModuleWidget {
	EvaluatorWidget(Evaluator *module) : ModuleWidget(module) {
		setPanel(SVG::load(assetPlugin(plugin, "res/Evaluator.svg")));

		addChild(Widget::create<ScrewSilver>(Vec(RACK_GRID_WIDTH, 0)));
		addChild(Widget::create<ScrewSilver>(Vec(box.size.x - 2 * RACK_GRID_WIDTH, 0)));
		addChild(Widget::create<ScrewSilver>(Vec(RACK_GRID_WIDTH, RACK_GRID_HEIGHT - RACK_GRID_WIDTH)));
		addChild(Widget::create<ScrewSilver>(Vec(box.size.x - 2 * RACK_GRID_WIDTH, RACK_GRID_HEIGHT - RACK_GRID_WIDTH)));

		addInput(Port::create<PJ301MPort>(Vec(18, 185), Port::INPUT, module, Evaluator::INPUT_1));
		addInput(Port::create<PJ301MPort>(Vec(48, 185), Port::INPUT, module, Evaluator::INPUT_2));
		addInput(Port::create<PJ301MPort>(Vec(18, 215), Port::INPUT, module, Evaluator::INPUT_3));
		addInput(Port::create<PJ301MPort>(Vec(48, 215), Port::INPUT, module, Evaluator::INPUT_4));

		addOutput(Port::create<PJ301MPort>(Vec(18, 275), Port::OUTPUT, module, Evaluator::OUTPUT_1));
		addOutput(Port::create<PJ301MPort>(Vec(48, 275), Port::OUTPUT, module, Evaluator::OUTPUT_2));
		addOutput(Port::create<PJ301MPort>(Vec(18, 305), Port::OUTPUT, module, Evaluator::OUTPUT_3));
		addOutput(Port::create<PJ301MPort>(Vec(48, 305), Port::OUTPUT, module, Evaluator::OUTPUT_4));
	}
};


// Specify the Module and ModuleWidget subclass, human-readable
// manufacturer name for categorization, module slug (should never
// change), human-readable module name, and any number of tags
// (found in `include/tags.hpp`) separated by commas.
Model *modelEvaluator = Model::create<Evaluator, EvaluatorWidget>("Elastic Orange", "ElasticOrange-Evaluator4x4", "Evaluator 4x4", OSCILLATOR_TAG);
