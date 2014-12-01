// AweSim STL Renderer

"use strict";

/* global THREE:false */

var ASTL = { REVISION: '1' };

//----------------------------//

// Global variables

ASTL.parent_stl;

ASTL.camera;
ASTL.controls;
ASTL.scene;
ASTL.renderer;

//----------------------------//

ASTL.STLObject = function ( name, file, color ) {

    // Name of STL object
    this.name = name;

    // Filename of STL mesh
    this.file = file;

    // Initial color (note: this can't be used to change color later)
    this.color = color;

    // Mesh object
    this.mesh = undefined;

    // Whether loaded or not?
    this.loaded = false;

    // Hash of children stl objects
    this.children = {};

    // Node id in canvas-menu
    this.node_id = "stl-object|" + name;

};

ASTL.STLObject.prototype = {

    constructor: ASTL.STLObject,

    add: function ( name, file, color ) {

        // Add child stl object to this parent
        this.children[ name ] = new ASTL.STLObject( name, file, color );

    },

    find: function ( name ) {

        // It is either a child of parent or the parent
        if ( name in this.children )
            return this.children[ name ];
        else
            return this;

    },

    meshLoader: function () {

        var _this = this;

        return function( geometry ) {

            // Create STL mesh
            var material = new THREE.MeshPhongMaterial({
                ambient: _this.color,
                color: _this.color,
                specular: 0x111111,
                shininess: 200,
                side: THREE.DoubleSide
            });

            _this.mesh = new THREE.Mesh( geometry, material );

            // Render mesh
            ASTL.scene.add( _this.mesh );
            ASTL.render();

            // Add this item to the canvas-menu
            _this.addHTML();

            // Store that this mesh is loaded
            _this.loaded = true;

            // Check if all the meshes are done loading
            if ( ASTL.parent_stl.isDoneLoading() ) ASTL.doneLoading();

        };

    },

    addHTML: function () {

        var info = document.querySelector( '#canvas-menu' );

        var content = "";
        content += "<ul id=\"" + this.node_id + "\">";
        content += "<li>";
        content += "<strong>" + this.name + ":</strong>&nbsp;";
        content += "</li><li>";
        content += this.getColorBarHTML();
        content += "</li><li>";
        content += this.getColorHTML();
        content += "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;";
        content += this.getTransparentHTML();
        content += "</li>";
        content += "</ul>";

        info.insertAdjacentHTML( 'beforeend', content );

    },

    getColorBarHTML: function () {

        return "<div class=\"stl-color-bar\" style=\"background-color:" + this.color + ";\"></div>";

    },

    getColorHTML: function () {

        var content = "";
        content += "Color: ";
        content += "<input type=\"color\" name=\"color\" value=\"" + this.color + "\" ";
        content += "onchange=\"ASTL.changeColor(this, \'" + this.name + "\')\"";
        content += ">";
        return content;

    },

    getTransparentHTML: function () {

        var content = "";
        content += "<input type=\"checkbox\" name=\"transparent\" ";
        content += "onclick=\"ASTL.changeTransparency(this, \'" + this.name + "\')\"";
        content += ">";
        content += "Hide";
        return content;

    },

    setColorBar: function ( css_color ) {

        // Get color bar node using css styling
        // e.g.: "stl-object|name" => "#stl-object\\|name .stl-color-bar"
        var css_id = "#" + this.node_id.replace( /(:|\.|\[|\]|\|)/g, "\\$1" ) + " .stl-color-bar";
        var colorbar_node = document.querySelector( css_id );

        // Change color of color bar
        colorbar_node.style.backgroundColor = css_color;

    },

    setColor: function ( css_color ) {

        var color = new THREE.Color( css_color );

        // Change the color of the material for this mesh
        this.mesh.material.color = color;
        this.mesh.material.ambient = color;

    },

    setVisible: function ( is_visible ) {

        // Make mesh visible or not in canvas
        this.mesh.material.visible = is_visible;

    },

    getCenteringMatrix: function () {

        // Bounding sphere for this STL object
        var x = this.mesh.geometry.boundingSphere.center.x;
        var y = this.mesh.geometry.boundingSphere.center.y;
        var z = this.mesh.geometry.boundingSphere.center.z;
        var r = this.mesh.geometry.boundingSphere.radius;

        // Translate it to the center
        var mT = new THREE.Matrix4();
        mT.makeTranslation( -x, -y, -z );

        // Scale it to a radius of 1.0
        var mS = new THREE.Matrix4();
        mS.makeScale( 1.0/r, 1.0/r, 1.0/r );

        // Make single transformation matrix
        var m = new THREE.Matrix4();
        m.multiplyMatrices(mS, mT);

        return m;

    },

    isDoneLoading: function () {

        // Check if this object and all of its children are done loading

        if ( !this.loaded ) return false;

        for ( var key in this.children ) {

            var child = this.children[ key ];

            if ( !child.isDoneLoading() ) return false;

        }

        return true;

    }

};

//----------------------------//

// Change color of stl object

ASTL.changeColor = function ( dom_element, stl_name ) {

    var color = dom_element.value;

    // Change color of the mesh
    var stl_object = ASTL.parent_stl.find( stl_name );
    stl_object.setColor( color );

    // Change background color for color bar of this mesh
    stl_object.setColorBar( color );

    ASTL.render();

};

//----------------------------//

// Checkbox to turn on/off transparency for base material

ASTL.changeTransparency = function ( dom_element, stl_name ) {

    var checked = dom_element.checked;

    // Toggle visibility of this mesh
    var stl_object = ASTL.parent_stl.find( stl_name );
    stl_object.setVisible( !checked );

    ASTL.render();

};

//----------------------------//

ASTL.startLoading = function ( parent_stl_object, loader ) {

    // set parent stl object as global variable

    ASTL.parent_stl = parent_stl_object;


    // canvas dimensions

    var canvas_width = document.querySelector( '#canvas' ).offsetWidth;
    var canvas_height = document.querySelector( '#canvas' ).offsetHeight;

    // camera

    ASTL.camera = new THREE.PerspectiveCamera( 60, canvas_width / canvas_height, 0.1, 1000 );
    ASTL.camera.position.x = 0.6;
    ASTL.camera.position.y = 1.2;
    ASTL.camera.position.z = 1.6;

    // renderer

    ASTL.renderer = new THREE.WebGLRenderer({ antialias: true });
    ASTL.renderer.setSize( canvas_width, canvas_height );

    var container = document.querySelector( '#canvas' );
    container.appendChild( ASTL.renderer.domElement );

    // trackball controls

    ASTL.controls = new THREE.TrackballControls( ASTL.camera, container );

    ASTL.controls.rotateSpeed = 1.0;
    ASTL.controls.zoomSpeed = 1.2;
    ASTL.controls.panSpeed = 0.8;

    ASTL.controls.noZoom = false;
    ASTL.controls.noPan = false;

    ASTL.controls.staticMoving = true;
    ASTL.controls.dynamicDampingFactor = 0.3;

    ASTL.controls.keys = [65, 83, 68];

    ASTL.controls.addEventListener('change', ASTL.render);

    // world

    ASTL.scene = new THREE.Scene();

    // lights

    ASTL.scene.add( new THREE.AmbientLight( 0x888888 ) );

    var directionalLight = new THREE.DirectionalLight( 0xffffff, 0.8 );
    directionalLight.position.set( 1, 1, 1 );
    ASTL.scene.add( directionalLight );

    var directionalLight2 = new THREE.DirectionalLight( 0xffffff, 0.8 );
    directionalLight2.position.set( -1, -1, -1 );
    ASTL.scene.add( directionalLight2 );

    var directionalLight3 = new THREE.DirectionalLight( 0xffffff, 0.8 );
    directionalLight3.position.set( 1, -1, 1 );
    ASTL.scene.add( directionalLight3 );

    var directionalLight4 = new THREE.DirectionalLight( 0xffffff, 0.8 );
    directionalLight4.position.set( -1, 1, -1 );
    ASTL.scene.add( directionalLight4 );

    // stl loader

    loader.load( ASTL.parent_stl.file, ASTL.parent_stl.meshLoader() );
    for ( var key in ASTL.parent_stl.children ) {
        var stl_object = ASTL.parent_stl.children[ key ];
        loader.load( stl_object.file, stl_object.meshLoader() );
    }

    // axis

    var axisHelper = new THREE.AxisHelper( 5 );
    ASTL.scene.add( axisHelper );

    // animate

    ASTL.animate();

};

//----------------------------//

// This function runs when all meshes are done loading

ASTL.doneLoading = function () {

    // Get transformation matrix that centers parent stl object
    var m = ASTL.parent_stl.getCenteringMatrix();

    // Center the entire scene using this matrix
    ASTL.scene.applyMatrix(m);

    ASTL.render();

};

//----------------------------//

ASTL.animate = function () {

    window.requestAnimationFrame( ASTL.animate );
    ASTL.controls.update();

};

//----------------------------//

ASTL.render = function () {

    ASTL.renderer.render( ASTL.scene, ASTL.camera );

};
