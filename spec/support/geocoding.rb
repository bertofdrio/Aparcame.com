#encoding: UTF-8

google_json = <<-JSON
{
  "status": "OK",
  "results": [ {
    "types": [ "street_address" ],
    "formatted_address": "4 Penn Plaza, New York, NY 10001, USA",
    "address_components": [ {
      "long_name": "4",
      "short_name": "4",
      "types": [ "street_number" ]
    }, {
      "long_name": "Penn Plaza",
      "short_name": "Penn Plaza",
      "types": [ "route" ]
    }, {
      "long_name": "Manhattan",
      "short_name": "Manhattan",
      "types": [ "sublocality", "political" ]
    }, {
      "long_name": "New York",
      "short_name": "New York",
      "types": [ "locality", "political" ]
    }, {
      "long_name": "New York",
      "short_name": "New York",
      "types": [ "administrative_area_level_2", "political" ]
    }, {
      "long_name": "New York",
      "short_name": "NY",
      "types": [ "administrative_area_level_1", "political" ]
    }, {
      "long_name": "United States",
      "short_name": "US",
      "types": [ "country", "political" ]
    }, {
      "long_name": "10001",
      "short_name": "10001",
      "types": [ "postal_code" ]
    } ],
    "geometry": {
      "location": {
        "lat": 40.7503540,
        "lng": -73.9933710
      },
      "location_type": "ROOFTOP",
      "viewport": {
        "southwest": {
          "lat": 40.7473324,
          "lng": -73.9965316
        },
        "northeast": {
          "lat": 40.7536276,
          "lng": -73.9902364
        }
      },
      "bounds": {
        "northeast" : {
           "lat" : 40.751161,
           "lng" : -73.9925922
        },
        "southwest" : {
           "lat" : 40.7498531,
           "lng" : -73.9944444
        }
      }
    }
  } ]
}
JSON

google_json_alternates = <<-JSON
{
  "status": "OK",
  "results": [ {
    "types": [ "street_address" ],
    "formatted_address": "45 Main Street, Long Road, Neverland, England",
    "address_components": [ {
      "long_name": "Calle Uria",
      "short_name": "45 Main Street, Long Road",
      "types": [ "route" ]
    }, {
      "long_name": "Oviedo",
      "short_name": "Neverland",
      "types": [ "city", "political" ]
    }, {
      "long_name": "England",
      "short_name": "UK",
      "types": [ "country", "political" ]
    } ],
    "geometry": {
      "location": {
        "lat": 0.0,
        "lng": 0.0
      }
    }
  }

  {
    "types": [ "street_address" ],
    "formatted_address": "45 Main Street, Long Road, Neverland, England",
    "address_components": [ {
      "long_name": "Calle Uría",
      "short_name": "45 Main Street, Long Road",
      "types": [ "route" ]
    }, {
      "long_name": "Gijón",
      "short_name": "Neverland",
      "types": [ "city", "political" ]
    }, {
      "long_name": "England",
      "short_name": "UK",
      "types": [ "country", "political" ]
    } ],
    "geometry": {
      "location": {
        "lat": 0.0,
        "lng": 0.0
      }
    }
  }
]
}
JSON

def register_without_alternates
  google_json = <<-JSON
{
  "status": "OK",
  "results": [ {
    "types": [ "street_address" ],
    "formatted_address": "4 Penn Plaza, New York, NY 10001, USA",
    "address_components": [ {
      "long_name": "4",
      "short_name": "4",
      "types": [ "street_number" ]
    }, {
      "long_name": "Penn Plaza",
      "short_name": "Penn Plaza",
      "types": [ "route" ]
    }, {
      "long_name": "Manhattan",
      "short_name": "Manhattan",
      "types": [ "sublocality", "political" ]
    }, {
      "long_name": "New York",
      "short_name": "New York",
      "types": [ "locality", "political" ]
    }, {
      "long_name": "New York",
      "short_name": "New York",
      "types": [ "administrative_area_level_2", "political" ]
    }, {
      "long_name": "New York",
      "short_name": "NY",
      "types": [ "administrative_area_level_1", "political" ]
    }, {
      "long_name": "United States",
      "short_name": "US",
      "types": [ "country", "political" ]
    }, {
      "long_name": "10001",
      "short_name": "10001",
      "types": [ "postal_code" ]
    } ],
    "geometry": {
      "location": {
        "lat": 40.7503540,
        "lng": -73.9933710
      },
      "location_type": "ROOFTOP",
      "viewport": {
        "southwest": {
          "lat": 40.7473324,
          "lng": -73.9965316
        },
        "northeast": {
          "lat": 40.7536276,
          "lng": -73.9902364
        }
      },
      "bounds": {
        "northeast" : {
           "lat" : 40.751161,
           "lng" : -73.9925922
        },
        "southwest" : {
           "lat" : 40.7498531,
           "lng" : -73.9944444
        }
      }
    }
  } ]
}
  JSON

  FakeWeb.register_uri(:any, %r|http://maps\.googleapis\.com/maps/api/geocode|, :body => google_json)
end

def register_with_alternates
  google_json_alternates = <<-JSON
{
  "status": "OK",
  "results": [ {
    "types": [ "street_address" ],
    "formatted_address": "4 Penn Plaza, New York, NY 10001, USA",
    "address_components": [ {
      "long_name": "Calle Uría",
      "short_name": "4",
      "types": [ "street_number" ]
    }, {
      "long_name": "Oviedo",
      "short_name": "Penn Plaza",
      "types": [ "route" ]
    }, {
      "long_name": "Manhattan",
      "short_name": "Manhattan",
      "types": [ "sublocality", "political" ]
    }, {
      "long_name": "New York",
      "short_name": "New York",
      "types": [ "locality", "political" ]
    }, {
      "long_name": "New York",
      "short_name": "New York",
      "types": [ "administrative_area_level_2", "political" ]
    }, {
      "long_name": "New York",
      "short_name": "NY",
      "types": [ "administrative_area_level_1", "political" ]
    }, {
      "long_name": "United States",
      "short_name": "US",
      "types": [ "country", "political" ]
    }, {
      "long_name": "10001",
      "short_name": "10001",
      "types": [ "postal_code" ]
    } ],
    "geometry": {
      "location": {
        "lat": 40.7503540,
        "lng": -73.9933710
      },
      "location_type": "ROOFTOP",
      "viewport": {
        "southwest": {
          "lat": 40.7473324,
          "lng": -73.9965316
        },
        "northeast": {
          "lat": 40.7536276,
          "lng": -73.9902364
        }
      },
      "bounds": {
        "northeast" : {
           "lat" : 40.751161,
           "lng" : -73.9925922
        },
        "southwest" : {
           "lat" : 40.7498531,
           "lng" : -73.9944444
        }
      }
    }
  },

{
    "types": [ "street_address" ],
    "formatted_address": "4 Penn Plaza, New York, NY 10001, USA",
    "address_components": [ {
      "long_name": "Calle Uría",
      "short_name": "4",
      "types": [ "street_number" ]
    }, {
      "long_name": "Gijón",
      "short_name": "Penn Plaza",
      "types": [ "route" ]
    }, {
      "long_name": "Manhattan",
      "short_name": "Manhattan",
      "types": [ "sublocality", "political" ]
    }, {
      "long_name": "New York",
      "short_name": "New York",
      "types": [ "locality", "political" ]
    }, {
      "long_name": "New York",
      "short_name": "New York",
      "types": [ "administrative_area_level_2", "political" ]
    }, {
      "long_name": "New York",
      "short_name": "NY",
      "types": [ "administrative_area_level_1", "political" ]
    }, {
      "long_name": "United States",
      "short_name": "US",
      "types": [ "country", "political" ]
    }, {
      "long_name": "10001",
      "short_name": "10001",
      "types": [ "postal_code" ]
    } ],
    "geometry": {
      "location": {
        "lat": 40.7503540,
        "lng": -73.9933710
      },
      "location_type": "ROOFTOP",
      "viewport": {
        "southwest": {
          "lat": 40.7473324,
          "lng": -73.9965316
        },
        "northeast": {
          "lat": 40.7536276,
          "lng": -73.9902364
        }
      },
      "bounds": {
        "northeast" : {
           "lat" : 40.751161,
           "lng" : -73.9925922
        },
        "southwest" : {
           "lat" : 40.7498531,
           "lng" : -73.9944444
        }
      }
    }
  }

,

{
    "types": [ "street_address" ],
    "formatted_address": "4 Penn Plaza, New York, NY 10001, USA",
    "address_components": [ {
      "long_name": "Calle Uría",
      "short_name": "4",
      "types": [ "street_number" ]
    }, {
      "long_name": "Madrid",
      "short_name": "Penn Plaza",
      "types": [ "route" ]
    }, {
      "long_name": "Manhattan",
      "short_name": "Manhattan",
      "types": [ "sublocality", "political" ]
    }, {
      "long_name": "New York",
      "short_name": "New York",
      "types": [ "locality", "political" ]
    }, {
      "long_name": "New York",
      "short_name": "New York",
      "types": [ "administrative_area_level_2", "political" ]
    }, {
      "long_name": "New York",
      "short_name": "NY",
      "types": [ "administrative_area_level_1", "political" ]
    }, {
      "long_name": "United States",
      "short_name": "US",
      "types": [ "country", "political" ]
    }, {
      "long_name": "10001",
      "short_name": "10001",
      "types": [ "postal_code" ]
    } ],
    "geometry": {
      "location": {
        "lat": 40.7503540,
        "lng": -73.9933710
      },
      "location_type": "ROOFTOP",
      "viewport": {
        "southwest": {
          "lat": 40.7473324,
          "lng": -73.9965316
        },
        "northeast": {
          "lat": 40.7536276,
          "lng": -73.9902364
        }
      },
      "bounds": {
        "northeast" : {
           "lat" : 40.751161,
           "lng" : -73.9925922
        },
        "southwest" : {
           "lat" : 40.7498531,
           "lng" : -73.9944444
        }
      }
    }
  }
]
}
  JSON

  FakeWeb.register_uri(:any, %r|http://maps\.googleapis\.com/maps/api/geocode|, :body => google_json_alternates)
end