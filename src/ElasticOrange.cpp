#include "ElasticOrange.hpp"
#include <chicken.h>


Plugin *plugin;


void init(rack::Plugin *p) {
    plugin = p;
    p->slug = TOSTRING(SLUG);
    p->version = TOSTRING(VERSION);

    // Add all Models defined throughout the plugin
    p->addModel(modelEvaluator);
}
