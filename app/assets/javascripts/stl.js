// AweSim STL Renderer

"use strict";

/* global THREE:false */

var ASTL = { REVISION: '2' };

//----------------------------//

// Global variables

ASTL.parent_stl;

ASTL.camera;
ASTL.controls;
ASTL.scene;
ASTL.renderer;

//----------------------------//

// Define loaders here

ASTL.Loaders = {

    "stl": THREE.STLLoader,
    "vtk": THREE.VTKLoader

};

ASTL.newLoader = function ( type ) {

    if ( type in ASTL.Loaders ) {

        return new ASTL.Loaders[ type ]();

    } else {

        return new THREE.STLLoader();

    }

};

ASTL.addLoader = function ( type, object ) {

    ASTL.Loaders[ type ] = object;

};

//----------------------------//

ASTL.STLObject = function ( parent_node, child_nodes ) {

    // Root <li> node of this <a href> node
    this.root_node = parent_node.parentNode;

    // Name of STL object
    this.name = parent_node.textContent;

    // Filename of STL mesh
    this.file = parent_node.href;

    // Initial color
    this.init_color = parent_node.dataset.color || "#ffffff";

    // Mesh object
    this.mesh = undefined;

    // Whether loaded or not?
    this.loaded = false;

    // Hash of children stl objects
    this.children = {};

    // Remove <a href> node
    this.root_node.removeChild( parent_node );

    // Display HTML menu for this object
    this.addHTML();

    // Add children if they exist
    if ( child_nodes !== undefined ) {

        for ( var i = 0; i < child_nodes.length; i++ ) {

            var name = child_nodes[i].textContent;

            this.children[ name ] = new ASTL.STLObject( child_nodes[i] );

        }

    }

};

ASTL.STLObject.prototype = {

    constructor: ASTL.STLObject,

    load: function ( loader ) {

        // Load geometry from file using specified loader
        // then call meshLoader when done
        loader.load( this.file, this.meshLoader() );

        // Repeat for children
        for ( var key in this.children ) {

            this.children[ key ].load( loader );

        }

    },

    meshLoader: function () {

        var _this = this;

        return function( geometry ) {

            // Create STL mesh
            var material = new THREE.MeshPhongMaterial({
                ambient: _this.init_color,
                color: _this.init_color,
                specular: 0x111111,
                shininess: 200,
                side: THREE.DoubleSide
            });

            _this.mesh = new THREE.Mesh( geometry, material );

            // Render mesh
            ASTL.scene.add( _this.mesh );
            ASTL.render();

            // Remove "Loading..." HTML
            var loading_node = _this.root_node.querySelector( ".astl-loading-color-bar" );
            loading_node.classList.remove( "astl-loading-color-bar" );

            // Store that this mesh is loaded
            _this.loaded = true;

            // Check if all the meshes are done loading
            if ( ASTL.parent_stl.isDoneLoading() ) ASTL.doneLoading();

        };

    },

    addHTML: function () {

        // HTML view
        this.addColorBarHTML();

        var elem = document.createElement( "div" );
        elem.className = "astl-item";

        elem.appendChild( this.addName() );
        elem.appendChild( this.addColor() );
        elem.appendChild( this.addToggle() );
        //this.addNameHTML();
        //this.addColorHTML();
        //this.addToggleHTML();

        this.root_node.appendChild( elem );

    },

    addColorBarHTML: function () {

        var elem = document.createElement( "div" );
        elem.className = "astl-color-bar astl-loading-color-bar";
        elem.style.backgroundColor = this.init_color;

        this.root_node.appendChild( elem );

    },

    addName: function () {

        var elem = document.createElement( "div" );
        elem.className = "astl-name";
        elem.textContent = this.name;

        return elem;

    },

    addColor: function () {

        var elem = document.createElement( "div" );
        elem.className = "astl-color";

        var label = document.createElement( "label" );
        label.htmlFor = "astl-color_" + this.name;
        //label.textContent = "color:";

        var input = document.createElement( "input" );
        input.id = label.htmlFor;
        input.type = "color";
        input.value = this.init_color;

        var _this = this;
        input.onchange = function () {
            _this.changeColor( input );
        };

        elem.appendChild( label );
        elem.appendChild( input );

        return elem;

    },

    addToggle: function () {

        var elem = document.createElement( "div" );
        elem.className = "astl-toggle";

        var label = document.createElement( "label" );
        label.htmlFor = "astl-toggle_" + this.name;

        var input = document.createElement( "input" );
        input.id = label.htmlFor;
        input.type = "checkbox";
        input.checked = true;

        var _this = this;
        input.onclick = function () {
            _this.changeToggle( input );
        };

        elem.appendChild( input );
        elem.appendChild( label );

        return elem;

    },

    changeColor: function ( dom_element ) {

        var color = dom_element.value;

        // Change color of mesh and color bar
        this.setColor( color );
        this.setColorBar( color );

        ASTL.render();

    },

    changeToggle: function ( dom_element ) {

        var checked = dom_element.checked;

        // Set this mesh visible or not
        this.setVisible( checked );

        ASTL.render();

    },

    setColor: function ( css_color ) {

        var color = new THREE.Color( css_color );

        // Change the color of the material for this mesh
        this.mesh.material.color = color;
        this.mesh.material.ambient = color;

    },

    setColorBar: function ( css_color ) {

        // Change color of color bar node
        var colorbar_node = this.root_node.querySelector( ".astl-color-bar" );
        colorbar_node.style.backgroundColor = css_color;

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

    applyMatrix: function( matrix ) {

        // Apply matrix to mesh
        this.mesh.applyMatrix( matrix );

        // Repeat for children
        for ( var key in this.children ) {

            this.children[ key ].applyMatrix( matrix );

        }

    },

    isDoneLoading: function () {

        // Check if done loading
        if ( !this.loaded ) return false;

        // Repeat check for children
        for ( var key in this.children ) {

            if ( !this.children[ key ].isDoneLoading() ) return false;

        }

        return true;

    }

};

//----------------------------//

// This function runs when all meshes are done loading

ASTL.doneLoading = function () {

    // Get transformation matrix that centers parent stl object
    var m = ASTL.parent_stl.getCenteringMatrix();

    // Center the entire scene using this matrix
    ASTL.parent_stl.applyMatrix(m);

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

//----------------------------//

// Initialization

window.onload = function () {

    // Get stl viewer and the canvas and file list corresponding
    // to the viewer
    var stl_viewer = document.querySelector( '.astl-viewer' );
    var stl_canvas = stl_viewer.querySelector( '.astl-canvas' );
    var stl_parent_node = stl_viewer.querySelector( 'a.astl-parent' );
    var stl_child_nodes = stl_viewer.querySelectorAll( '.astl-files > li a:not(.astl-parent)' );

    // make objects

    ASTL.parent_stl = new ASTL.STLObject( stl_parent_node, stl_child_nodes );

    // canvas dimensions

    var canvas_width = stl_canvas.offsetWidth;
    var canvas_height = stl_canvas.offsetHeight;

    // camera

    ASTL.camera = new THREE.PerspectiveCamera( 60, canvas_width / canvas_height, 0.1, 1000 );
    ASTL.camera.position.x = 0.6;
    ASTL.camera.position.y = 1.2;
    ASTL.camera.position.z = 1.6;

    // renderer

    ASTL.renderer = new THREE.WebGLRenderer({ antialias: true });
    ASTL.renderer.setSize( canvas_width, canvas_height );

    var container = stl_canvas;
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

    var loader = ASTL.newLoader( stl_viewer.dataset.type );

    ASTL.parent_stl.load( loader );

    // axis

    var axisHelper = new THREE.AxisHelper( 5 );
    ASTL.scene.add( axisHelper );

    // animate

    ASTL.animate();

};
