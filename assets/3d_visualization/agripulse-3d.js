class AgriPulse3D {
    constructor() {
        this.scene = null;
        this.camera = null;
        this.renderer = null;
        this.controls = null;

        // Central Burundi map
        this.centralNode = null;
        this.regions = [];

        // Orbiting satellites (data streams)
        this.satellites = [];
        this.satelliteData = [
            { name: 'Coffee Prices', type: 'prices', status: 'threat', angle: 0 },
            { name: 'Weather Data', type: 'weather', status: 'watch', angle: Math.PI / 3 },
            { name: 'Disease Reports', type: 'disease', status: 'opportunity', angle: 2 * Math.PI / 3 },
            { name: 'Market Data', type: 'market', status: 'watch', angle: Math.PI },
            { name: 'News Feed', type: 'news', status: 'threat', angle: 4 * Math.PI / 3 },
            { name: 'Exchange Rates', type: 'currency', status: 'opportunity', angle: 5 * Math.PI / 3 }
        ];

        // Connection lines and pulses
        this.connections = [];
        this.pulses = [];

        // Animation properties
        this.time = 0;
        this.orbitRadius = 8;
        this.orbitSpeed = 0.01;

        // Real data integration
        this.dataService = new RealDataService();
        this.realDataEnabled = false;

        this.init();
    }

    init() {
        this.createScene();
        this.createCentralNode();
        this.createSatellites();
        this.createConnections();
        this.setupLighting();
        this.setupControls();
        this.animate();

        // Hide loading screen
        document.getElementById('loading').style.display = 'none';

        // Start data simulation
        this.simulateDataStreams();
    }

    createScene() {
        // Scene setup
        this.scene = new THREE.Scene();
        this.scene.background = new THREE.Color(0x0a0a0a);

        // Camera setup
        this.camera = new THREE.PerspectiveCamera(
            75,
            window.innerWidth / window.innerHeight,
            0.1,
            1000
        );
        this.camera.position.set(0, 5, 15);

        // Renderer setup
        this.renderer = new THREE.WebGLRenderer({ antialias: true });
        this.renderer.setSize(window.innerWidth, window.innerHeight);
        this.renderer.shadowMap.enabled = true;
        this.renderer.shadowMap.type = THREE.PCFSoftShadowMap;
        this.renderer.toneMapping = THREE.ReinhardToneMapping;
        this.renderer.toneMappingExposure = 1.5;

        document.getElementById('container').appendChild(this.renderer.domElement);

        // Setup postprocessing
        this.setupPostprocessing();

        // Handle window resize
        window.addEventListener('resize', () => this.onWindowResize());
    }

    setupPostprocessing() {
        // Create effect composer
        this.composer = new THREE.EffectComposer(this.renderer);

        // Add render pass
        const renderPass = new THREE.RenderPass(this.scene, this.camera);
        this.composer.addPass(renderPass);

        // Add bloom pass for glowing effects
        const bloomPass = new THREE.UnrealBloomPass(
            new THREE.Vector2(window.innerWidth, window.innerHeight),
            1.5,  // strength
            0.4,  // radius
            0.85  // threshold
        );
        this.composer.addPass(bloomPass);

        // Store bloom pass for dynamic adjustment
        this.bloomPass = bloomPass;
    }

    createCentralNode() {
        // Create realistic 3D Burundi terrain
        this.createBurundiTerrain();

        // Add coffee regions as glowing points
        this.createCoffeeRegions();

        // Add pulsing ring around central node
        this.createPulsingRing();

        // Add atmospheric effects
        this.createAtmosphere();
    }

    createBurundiTerrain() {
        // Create real Burundi map using satellite/map tiles
        this.createRealBurundiMap();
    }

    async createRealBurundiMap() {
        // Burundi bounding box coordinates
        const bounds = {
            north: -2.3,   // Northern border
            south: -4.5,   // Southern border  
            west: 28.9,    // Western border
            east: 30.9     // Eastern border
        };

        // Create geometry for the map plane
        const width = 6, height = 4;
        const geometry = new THREE.PlaneGeometry(width, height, 64, 64);

        // Load real map texture from OpenStreetMap
        const mapTexture = await this.loadMapTexture(bounds);
        
        // Create material with the real map texture
        const material = new THREE.MeshLambertMaterial({
            map: mapTexture,
            transparent: true,
            opacity: 0.9
        });

        this.centralNode = new THREE.Mesh(geometry, material);
        this.centralNode.rotation.x = -Math.PI / 2;
        this.centralNode.receiveShadow = true;
        this.scene.add(this.centralNode);

        // Add elevation data for 3D effect
        await this.addElevationData(geometry, bounds);

        // Add real country border
        this.createRealCountryBorder();
    }

    async loadMapTexture(bounds) {
        try {
            // First try Google Maps with your API key
            const googleTexture = await this.loadGoogleMapsTexture(bounds);
            if (googleTexture) {
                console.log('✅ Google Maps loaded successfully');
                return googleTexture;
            }
        } catch (error) {
            console.warn('Google Maps failed, trying OpenStreetMap:', error);
        }

        try {
            // Fallback to OpenStreetMap tiles
            const zoom = 8;
            const tileSize = 512;
            
            // Calculate tile coordinates for Burundi
            const centerLat = (bounds.north + bounds.south) / 2;
            const centerLon = (bounds.west + bounds.east) / 2;
            
            // Create canvas to composite map tiles
            const canvas = document.createElement('canvas');
            canvas.width = tileSize;
            canvas.height = tileSize;
            const ctx = canvas.getContext('2d');

            // Load satellite imagery from multiple sources
            const mapUrl = this.getMapTileUrl(centerLat, centerLon, zoom);
            
            const img = new Image();
            img.crossOrigin = 'anonymous';
            
            return new Promise((resolve) => {
                img.onload = () => {
                    ctx.drawImage(img, 0, 0, tileSize, tileSize);
                    
                    // Add coffee region overlays
                    this.addCoffeeRegionOverlays(ctx, bounds);
                    
                    const texture = new THREE.CanvasTexture(canvas);
                    texture.wrapS = THREE.ClampToEdgeWrapping;
                    texture.wrapT = THREE.ClampToEdgeWrapping;
                    resolve(texture);
                };
                
                img.onerror = () => {
                    // Fallback to generated map
                    this.createFallbackMap(ctx, canvas);
                    const texture = new THREE.CanvasTexture(canvas);
                    resolve(texture);
                };
                
                img.src = mapUrl;
            });
            
        } catch (error) {
            console.warn('Failed to load real map, using fallback:', error);
            return this.createFallbackMapTexture();
        }
    }

    getMapTileUrl(lat, lon, zoom) {
        // Using OpenStreetMap tiles (free)
        const x = Math.floor((lon + 180) / 360 * Math.pow(2, zoom));
        const y = Math.floor((1 - Math.log(Math.tan(lat * Math.PI / 180) + 1 / Math.cos(lat * Math.PI / 180)) / Math.PI) / 2 * Math.pow(2, zoom));
        
        // Multiple tile sources for better coverage
        const sources = [
            `https://tile.openstreetmap.org/${zoom}/${x}/${y}.png`,
            `https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/${zoom}/${y}/${x}`,
            `https://mt1.google.com/vt/lyrs=s&x=${x}&y=${y}&z=${zoom}` // Google Satellite (may have CORS issues)
        ];
        
        return sources[0]; // Start with OpenStreetMap
    }

    addCoffeeRegionOverlays(ctx, bounds) {
        // Add visual indicators for coffee growing regions
        const coffeeRegions = [
            { name: 'Kayanza', lat: -2.9217, lon: 29.6297 },
            { name: 'Ngozi', lat: -2.9083, lon: 29.8306 },
            { name: 'Muyinga', lat: -2.8444, lon: 30.3417 },
            { name: 'Kirundo', lat: -2.5833, lon: 30.0833 },
            { name: 'Gitega', lat: -3.4264, lon: 29.9306 }
        ];

        coffeeRegions.forEach(region => {
            // Convert lat/lon to canvas coordinates
            const x = ((region.lon - bounds.west) / (bounds.east - bounds.west)) * ctx.canvas.width;
            const y = ((bounds.north - region.lat) / (bounds.north - bounds.south)) * ctx.canvas.height;

            // Draw coffee region indicator
            ctx.fillStyle = 'rgba(111, 78, 55, 0.7)'; // Coffee brown
            ctx.beginPath();
            ctx.arc(x, y, 15, 0, 2 * Math.PI);
            ctx.fill();

            // Add white border
            ctx.strokeStyle = 'white';
            ctx.lineWidth = 2;
            ctx.stroke();

            // Add region name
            ctx.fillStyle = 'white';
            ctx.font = '12px Arial';
            ctx.textAlign = 'center';
            ctx.fillText(region.name, x, y - 20);
        });
    }

    async addElevationData(geometry, bounds) {
        try {
            // Add realistic elevation data for Burundi's mountainous terrain
            const vertices = geometry.attributes.position.array;
            
            // Burundi elevation patterns (higher in the east, lower near Lake Tanganyika)
            for (let i = 0; i < vertices.length; i += 3) {
                const x = vertices[i];
                const y = vertices[i + 1];
                
                // Convert to lat/lon coordinates
                const lon = bounds.west + ((x + 3) / 6) * (bounds.east - bounds.west);
                const lat = bounds.south + ((y + 2) / 4) * (bounds.north - bounds.south);
                
                // Simulate Burundi's real elevation patterns
                let elevation = 0;
                
                // Higher elevations in central highlands
                const distanceFromCenter = Math.sqrt(Math.pow(lon - 29.9, 2) + Math.pow(lat + 3.4, 2));
                elevation += Math.max(0, 1.5 - distanceFromCenter * 0.8);
                
                // Lower near Lake Tanganyika (western border)
                const distanceFromLake = Math.abs(lon - 29.0);
                elevation -= Math.max(0, 0.5 - distanceFromLake * 0.3);
                
                // Add some noise for realistic terrain
                elevation += (Math.random() - 0.5) * 0.2;
                
                vertices[i + 2] = elevation * 0.5; // Scale down for visualization
            }
            
            geometry.attributes.position.needsUpdate = true;
            geometry.computeVertexNormals();
            
        } catch (error) {
            console.warn('Failed to add elevation data:', error);
        }
    }

    createFallbackMap(ctx, canvas) {
        // Create a stylized map when real tiles fail to load
        const width = canvas.width;
        const height = canvas.height;

        // Background (land)
        ctx.fillStyle = '#8FBC8F'; // Light green
        ctx.fillRect(0, 0, width, height);

        // Add Lake Tanganyika (western border)
        ctx.fillStyle = '#4682B4'; // Steel blue
        ctx.fillRect(0, height * 0.2, width * 0.15, height * 0.6);

        // Add major rivers
        ctx.strokeStyle = '#4682B4';
        ctx.lineWidth = 3;
        ctx.beginPath();
        ctx.moveTo(width * 0.3, height * 0.1);
        ctx.lineTo(width * 0.5, height * 0.9);
        ctx.stroke();

        // Add coffee growing regions with different shades
        const regions = [
            { x: 0.3, y: 0.3, size: 0.15, color: '#6B4423' }, // Kayanza
            { x: 0.5, y: 0.25, size: 0.12, color: '#8B4513' }, // Ngozi  
            { x: 0.7, y: 0.4, size: 0.1, color: '#A0522D' },  // Muyinga
            { x: 0.6, y: 0.15, size: 0.08, color: '#CD853F' }, // Kirundo
            { x: 0.5, y: 0.7, size: 0.13, color: '#D2691E' }   // Gitega
        ];

        regions.forEach(region => {
            ctx.fillStyle = region.color;
            ctx.beginPath();
            ctx.arc(
                width * region.x, 
                height * region.y, 
                width * region.size, 
                0, 2 * Math.PI
            );
            ctx.fill();
        });

        // Add country border
        ctx.strokeStyle = '#FFFFFF';
        ctx.lineWidth = 2;
        ctx.beginPath();
        ctx.rect(width * 0.05, height * 0.05, width * 0.9, height * 0.9);
        ctx.stroke();
    }

    createFallbackMapTexture() {
        const canvas = document.createElement('canvas');
        canvas.width = 512;
        canvas.height = 512;
        const ctx = canvas.getContext('2d');
        
        this.createFallbackMap(ctx, canvas);
        
        return new THREE.CanvasTexture(canvas);
    }

    // Google Maps Integration with your API key
    async loadGoogleMapsTexture(bounds) {
        // Your Google Maps API key
        const apiKey = 'AIzaSyA6kCI_ITuLpWODKjCkaZ8NhUssyMoMNY8';
        
        console.log('🗺️ Loading Google Maps for Burundi coffee regions...');

        const center = `${(bounds.north + bounds.south) / 2},${(bounds.west + bounds.east) / 2}`;
        const zoom = 10; // Higher zoom for better detail
        const size = '640x640'; // Higher resolution
        const maptype = 'satellite'; // Perfect for coffee regions
        
        const googleMapsUrl = `https://maps.googleapis.com/maps/api/staticmap?` +
            `center=${center}&zoom=${zoom}&size=${size}&maptype=${maptype}&key=${apiKey}` +
            `&style=feature:poi|visibility:off` + // Hide points of interest for cleaner look
            `&style=feature:road|visibility:simplified`; // Simplify roads

        try {
            const img = new Image();
            img.crossOrigin = 'anonymous';
            
            return new Promise((resolve, reject) => {
                img.onload = () => {
                    const canvas = document.createElement('canvas');
                    canvas.width = 640;
                    canvas.height = 640;
                    const ctx = canvas.getContext('2d');
                    
                    // Draw the Google Maps image
                    ctx.drawImage(img, 0, 0, 640, 640);
                    
                    // Add coffee region overlays with enhanced styling
                    this.addEnhancedCoffeeRegionOverlays(ctx, bounds);
                    
                    const texture = new THREE.CanvasTexture(canvas);
                    texture.wrapS = THREE.ClampToEdgeWrapping;
                    texture.wrapT = THREE.ClampToEdgeWrapping;
                    resolve(texture);
                };
                
                img.onerror = () => {
                    console.warn('❌ Google Maps failed, falling back to OpenStreetMap');
                    resolve(null); // Return null to trigger fallback
                };
                
                img.src = googleMapsUrl;
            });
            
        } catch (error) {
            console.warn('Google Maps integration failed:', error);
            return null; // Return null to trigger fallback
        }
    }

    addEnhancedCoffeeRegionOverlays(ctx, bounds) {
        // Enhanced coffee region indicators for Google Maps
        const coffeeRegions = [
            { name: 'Kayanza', lat: -2.9217, lon: 29.6297, farmers: 120000, status: 'watch' },
            { name: 'Ngozi', lat: -2.9083, lon: 29.8306, farmers: 95000, status: 'threat' },
            { name: 'Muyinga', lat: -2.8444, lon: 30.3417, farmers: 75000, status: 'opportunity' },
            { name: 'Kirundo', lat: -2.5833, lon: 30.0833, farmers: 80000, status: 'opportunity' },
            { name: 'Gitega', lat: -3.4264, lon: 29.9306, farmers: 110000, status: 'watch' }
        ];

        coffeeRegions.forEach(region => {
            // Convert lat/lon to canvas coordinates
            const x = ((region.lon - bounds.west) / (bounds.east - bounds.west)) * ctx.canvas.width;
            const y = ((bounds.north - region.lat) / (bounds.north - bounds.south)) * ctx.canvas.height;

            // Status colors
            const statusColors = {
                'opportunity': 'rgba(76, 175, 80, 0.8)', // Green
                'watch': 'rgba(255, 193, 7, 0.8)',       // Yellow
                'threat': 'rgba(244, 67, 54, 0.8)'       // Red
            };

            // Draw main region circle
            ctx.fillStyle = statusColors[region.status] || 'rgba(111, 78, 55, 0.8)';
            ctx.beginPath();
            ctx.arc(x, y, 20, 0, 2 * Math.PI);
            ctx.fill();

            // Add white border
            ctx.strokeStyle = 'white';
            ctx.lineWidth = 3;
            ctx.stroke();

            // Add inner coffee bean symbol
            ctx.fillStyle = '#6F4E37'; // Coffee brown
            ctx.beginPath();
            ctx.arc(x, y, 8, 0, 2 * Math.PI);
            ctx.fill();

            // Add region name with background
            ctx.fillStyle = 'rgba(0, 0, 0, 0.7)';
            ctx.fillRect(x - 35, y - 35, 70, 16);
            
            ctx.fillStyle = 'white';
            ctx.font = 'bold 12px Arial';
            ctx.textAlign = 'center';
            ctx.fillText(region.name, x, y - 25);

            // Add farmer count
            ctx.fillStyle = 'rgba(0, 0, 0, 0.7)';
            ctx.fillRect(x - 30, y + 25, 60, 14);
            
            ctx.fillStyle = 'white';
            ctx.font = '10px Arial';
            ctx.fillText(`${(region.farmers / 1000).toFixed(0)}k farmers`, x, y + 35);

            // Add pulsing effect for active regions
            if (region.status === 'threat') {
                const time = Date.now() * 0.005;
                const pulse = Math.sin(time) * 0.3 + 0.7;
                
                ctx.globalAlpha = pulse * 0.5;
                ctx.fillStyle = 'red';
                ctx.beginPath();
                ctx.arc(x, y, 30, 0, 2 * Math.PI);
                ctx.fill();
                ctx.globalAlpha = 1;
            }
        });
    }

    // Enhanced map with multiple data layers
    async createEnhancedMap() {
        const bounds = {
            north: -2.3, south: -4.5, west: 28.9, east: 30.9
        };

        // Create base map
        const baseTexture = await this.loadMapTexture(bounds);
        
        // Create additional data layers
        const weatherLayer = this.createWeatherLayer(bounds);
        const priceLayer = this.createPriceLayer(bounds);
        const alertLayer = this.createAlertLayer(bounds);

        // Composite all layers
        const compositeTexture = this.compositeLayers([
            baseTexture,
            weatherLayer,
            priceLayer,
            alertLayer
        ]);

        return compositeTexture;
    }

    createWeatherLayer(bounds) {
        const canvas = document.createElement('canvas');
        canvas.width = 512;
        canvas.height = 512;
        const ctx = canvas.getContext('2d');

        // Create weather overlay (clouds, rain patterns, etc.)
        const weatherData = [
            { lat: -2.9, lon: 29.6, type: 'rain', intensity: 0.7 },
            { lat: -3.1, lon: 29.8, type: 'clouds', intensity: 0.5 },
            { lat: -2.7, lon: 30.2, type: 'clear', intensity: 0.2 }
        ];

        weatherData.forEach(weather => {
            const x = ((weather.lon - bounds.west) / (bounds.east - bounds.west)) * canvas.width;
            const y = ((bounds.north - weather.lat) / (bounds.north - bounds.south)) * canvas.height;

            ctx.globalAlpha = weather.intensity;
            
            if (weather.type === 'rain') {
                ctx.fillStyle = 'rgba(0, 100, 200, 0.3)';
            } else if (weather.type === 'clouds') {
                ctx.fillStyle = 'rgba(200, 200, 200, 0.4)';
            } else {
                ctx.fillStyle = 'rgba(255, 255, 0, 0.2)';
            }

            ctx.beginPath();
            ctx.arc(x, y, 50, 0, 2 * Math.PI);
            ctx.fill();
        });

        return new THREE.CanvasTexture(canvas);
    }

    createPriceLayer(bounds) {
        const canvas = document.createElement('canvas');
        canvas.width = 512;
        canvas.height = 512;
        const ctx = canvas.getContext('2d');

        // Create price heat map overlay
        const priceData = [
            { lat: -2.9217, lon: 29.6297, price: 4800, change: 2.3 },
            { lat: -2.9083, lon: 29.8306, price: 4750, change: -1.2 },
            { lat: -2.8444, lon: 30.3417, price: 4850, change: 3.1 }
        ];

        priceData.forEach(data => {
            const x = ((data.lon - bounds.west) / (bounds.east - bounds.west)) * canvas.width;
            const y = ((bounds.north - data.lat) / (bounds.north - bounds.south)) * canvas.height;

            // Color based on price change
            let color;
            if (data.change > 0) {
                color = `rgba(0, 255, 0, ${Math.min(data.change / 5, 0.6)})`;
            } else {
                color = `rgba(255, 0, 0, ${Math.min(Math.abs(data.change) / 5, 0.6)})`;
            }

            ctx.fillStyle = color;
            ctx.beginPath();
            ctx.arc(x, y, 30, 0, 2 * Math.PI);
            ctx.fill();
        });

        return new THREE.CanvasTexture(canvas);
    }

    createAlertLayer(bounds) {
        const canvas = document.createElement('canvas');
        canvas.width = 512;
        canvas.height = 512;
        const ctx = canvas.getContext('2d');

        // Create alert indicators
        const alerts = [
            { lat: -2.9, lon: 29.7, type: 'disease', severity: 'high' },
            { lat: -3.2, lon: 30.1, type: 'weather', severity: 'medium' }
        ];

        alerts.forEach(alert => {
            const x = ((alert.lon - bounds.west) / (bounds.east - bounds.west)) * canvas.width;
            const y = ((bounds.north - alert.lat) / (bounds.north - bounds.south)) * canvas.height;

            // Pulsing alert indicator
            const time = Date.now() * 0.005;
            const pulse = Math.sin(time) * 0.3 + 0.7;

            ctx.globalAlpha = pulse;
            ctx.fillStyle = alert.severity === 'high' ? 'red' : 'orange';
            ctx.beginPath();
            ctx.arc(x, y, 20, 0, 2 * Math.PI);
            ctx.fill();

            // Alert border
            ctx.strokeStyle = 'white';
            ctx.lineWidth = 2;
            ctx.stroke();
        });

        return new THREE.CanvasTexture(canvas);
    }

    compositeLayers(textures) {
        const canvas = document.createElement('canvas');
        canvas.width = 512;
        canvas.height = 512;
        const ctx = canvas.getContext('2d');

        // Draw each layer
        textures.forEach((texture, index) => {
            if (texture && texture.image) {
                ctx.globalCompositeOperation = index === 0 ? 'source-over' : 'multiply';
                ctx.drawImage(texture.image, 0, 0);
            }
        });

        return new THREE.CanvasTexture(canvas);
    }

    createRealCountryBorder() {
        // Real Burundi border coordinates (simplified)
        const realBorderPoints = [
            // Starting from northwest, going clockwise
            new THREE.Vector3(-2.9, 0.05, 1.9),   // Northwest
            new THREE.Vector3(-1.5, 0.05, 2.0),   // North
            new THREE.Vector3(0.5, 0.05, 1.8),    // Northeast  
            new THREE.Vector3(2.8, 0.05, 1.2),    // East
            new THREE.Vector3(2.9, 0.05, 0.0),    // Southeast
            new THREE.Vector3(2.5, 0.05, -1.5),   // South
            new THREE.Vector3(1.0, 0.05, -2.0),   // Southwest
            new THREE.Vector3(-1.5, 0.05, -1.8),  // West (Lake Tanganyika)
            new THREE.Vector3(-2.9, 0.05, -0.5),  // Northwest (Lake)
            new THREE.Vector3(-2.9, 0.05, 1.9)    // Close the border
        ];

        const borderGeometry = new THREE.BufferGeometry().setFromPoints(realBorderPoints);
        const borderMaterial = new THREE.LineBasicMaterial({
            color: 0xffffff,
            linewidth: 4,
            transparent: true,
            opacity: 0.9
        });

        const borderLine = new THREE.Line(borderGeometry, borderMaterial);
        this.scene.add(borderLine);

        // Add Lake Tanganyika border (western side)
        this.createLakeTanganyikaBorder();
    }

    createLakeTanganyikaBorder() {
        // Lake Tanganyika forms Burundi's western border
        const lakePoints = [
            new THREE.Vector3(-2.9, 0.02, 1.9),
            new THREE.Vector3(-2.9, 0.02, 1.0),
            new THREE.Vector3(-2.8, 0.02, 0.0),
            new THREE.Vector3(-2.7, 0.02, -1.0),
            new THREE.Vector3(-2.5, 0.02, -1.8)
        ];

        const lakeGeometry = new THREE.BufferGeometry().setFromPoints(lakePoints);
        const lakeMaterial = new THREE.LineBasicMaterial({
            color: 0x4682B4, // Steel blue for water
            linewidth: 6,
            transparent: true,
            opacity: 0.8
        });

        const lakeLine = new THREE.Line(lakeGeometry, lakeMaterial);
        this.scene.add(lakeLine);
    }

    createAtmosphere() {
        // Add atmospheric glow around the map
        const atmosphereGeometry = new THREE.SphereGeometry(12, 32, 32);
        const atmosphereMaterial = new THREE.ShaderMaterial({
            uniforms: {
                time: { value: 0 }
            },
            vertexShader: `
                varying vec3 vNormal;
                void main() {
                    vNormal = normalize(normalMatrix * normal);
                    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
                }
            `,
            fragmentShader: `
                uniform float time;
                varying vec3 vNormal;
                void main() {
                    float intensity = pow(0.7 - dot(vNormal, vec3(0, 0, 1.0)), 2.0);
                    gl_FragColor = vec4(0.4, 0.2, 0.1, 1.0) * intensity;
                }
            `,
            side: THREE.BackSide,
            blending: THREE.AdditiveBlending,
            transparent: true
        });

        this.atmosphere = new THREE.Mesh(atmosphereGeometry, atmosphereMaterial);
        this.scene.add(this.atmosphere);
    }

    createCoffeeRegions() {
        // Real Burundi coffee regions with accurate coordinates
        // Converted from lat/lon to 3D space coordinates
        const regionData = [
            { 
                name: 'Kayanza', 
                lat: -2.9217, 
                lon: 29.6297,
                x: -1.2, 
                z: 0.8, 
                status: 'watch',
                farmers: 120000,
                elevation: 1800 // meters above sea level
            },
            { 
                name: 'Ngozi', 
                lat: -2.9083, 
                lon: 29.8306,
                x: -0.3, 
                z: 0.9, 
                status: 'threat',
                farmers: 95000,
                elevation: 1850
            },
            { 
                name: 'Muyinga', 
                lat: -2.8444, 
                lon: 30.3417,
                x: 1.5, 
                z: 0.6, 
                status: 'opportunity',
                farmers: 75000,
                elevation: 1600
            },
            { 
                name: 'Kirundo', 
                lat: -2.5833, 
                lon: 30.0833,
                x: 0.5, 
                z: 1.7, 
                status: 'opportunity',
                farmers: 80000,
                elevation: 1500
            },
            { 
                name: 'Gitega', 
                lat: -3.4264, 
                lon: 29.9306,
                x: 0.2, 
                z: -1.2, 
                status: 'watch',
                farmers: 110000,
                elevation: 1700
            }
        ];

        regionData.forEach(region => {
            const geometry = new THREE.SphereGeometry(0.1, 16, 16);
            const color = this.getStatusColor(region.status);
            const material = new THREE.MeshPhongMaterial({
                color: color,
                emissive: color,
                emissiveIntensity: 0.3
            });

            const regionMesh = new THREE.Mesh(geometry, material);
            regionMesh.position.set(region.x, 0.1, region.z);
            regionMesh.userData = region;

            this.regions.push(regionMesh);
            this.scene.add(regionMesh);

            // Add glowing effect
            this.addGlowEffect(regionMesh, color);

            // Make regions clickable
            regionMesh.userData.clickable = true;
        });
    }

    createPulsingRing() {
        const geometry = new THREE.RingGeometry(3, 3.2, 32);
        const material = new THREE.MeshBasicMaterial({
            color: 0x6F4E37,
            transparent: true,
            opacity: 0.3,
            side: THREE.DoubleSide
        });

        const ring = new THREE.Mesh(geometry, material);
        ring.rotation.x = -Math.PI / 2;
        ring.position.y = 0.01;
        this.scene.add(ring);

        // Animate ring pulsing
        this.pulsingRing = ring;
    }

    createSatellites() {
        this.satelliteData.forEach((data, index) => {
            const satellite = this.createSatellite(data);
            this.satellites.push(satellite);
            this.scene.add(satellite.group);
        });
    }

    createSatellite(data) {
        const group = new THREE.Group();

        // Create realistic satellite structure
        const color = this.getStatusColor(data.status);

        // Main satellite body (cylindrical)
        const bodyGeometry = new THREE.CylinderGeometry(0.15, 0.15, 0.4, 8);
        const bodyMaterial = new THREE.MeshPhongMaterial({
            color: 0x888888,
            metalness: 0.8,
            roughness: 0.2
        });
        const body = new THREE.Mesh(bodyGeometry, bodyMaterial);
        group.add(body);

        // Solar panels
        const panelGeometry = new THREE.BoxGeometry(0.8, 0.02, 0.3);
        const panelMaterial = new THREE.MeshPhongMaterial({
            color: 0x001133,
            emissive: 0x000044,
            emissiveIntensity: 0.1
        });

        const panel1 = new THREE.Mesh(panelGeometry, panelMaterial);
        panel1.position.set(0.5, 0, 0);
        group.add(panel1);

        const panel2 = new THREE.Mesh(panelGeometry, panelMaterial);
        panel2.position.set(-0.5, 0, 0);
        group.add(panel2);

        // Status indicator (glowing sphere)
        const indicatorGeometry = new THREE.SphereGeometry(0.08, 16, 16);
        const indicatorMaterial = new THREE.MeshPhongMaterial({
            color: color,
            emissive: color,
            emissiveIntensity: 0.5
        });
        const indicator = new THREE.Mesh(indicatorGeometry, indicatorMaterial);
        indicator.position.set(0, 0.25, 0);
        group.add(indicator);

        // Communication dish
        const dishGeometry = new THREE.ConeGeometry(0.1, 0.15, 8);
        const dishMaterial = new THREE.MeshPhongMaterial({
            color: 0xcccccc
        });
        const dish = new THREE.Mesh(dishGeometry, dishMaterial);
        dish.position.set(0, -0.25, 0);
        dish.rotation.x = Math.PI;
        group.add(dish);

        // Add data stream visualization
        this.addDataStreamEffect(group, data);

        // Add label
        this.addSatelliteLabel(group, data.name);

        return {
            group: group,
            data: data,
            mesh: indicator // Use indicator for interactions
        };
    }

    addDataStreamEffect(group, data) {
        // Create particle system for data streams
        const particleCount = 20;
        const geometry = new THREE.BufferGeometry();
        const positions = new Float32Array(particleCount * 3);

        for (let i = 0; i < particleCount; i++) {
            positions[i * 3] = (Math.random() - 0.5) * 2;
            positions[i * 3 + 1] = (Math.random() - 0.5) * 2;
            positions[i * 3 + 2] = (Math.random() - 0.5) * 2;
        }

        geometry.setAttribute('position', new THREE.BufferAttribute(positions, 3));

        const material = new THREE.PointsMaterial({
            color: this.getStatusColor(data.status),
            size: 0.05,
            transparent: true,
            opacity: 0.6
        });

        const particles = new THREE.Points(geometry, material);
        group.add(particles);

        group.userData.particles = particles;
    }

    addSatelliteLabel(group, text) {
        // Create text label (simplified - in production, use TextGeometry or HTML overlay)
        const canvas = document.createElement('canvas');
        const context = canvas.getContext('2d');
        canvas.width = 256;
        canvas.height = 64;

        context.fillStyle = 'rgba(0, 0, 0, 0.8)';
        context.fillRect(0, 0, canvas.width, canvas.height);

        context.fillStyle = 'white';
        context.font = '16px Arial';
        context.textAlign = 'center';
        context.fillText(text, canvas.width / 2, canvas.height / 2 + 6);

        const texture = new THREE.CanvasTexture(canvas);
        const material = new THREE.SpriteMaterial({ map: texture });
        const sprite = new THREE.Sprite(material);
        sprite.scale.set(2, 0.5, 1);
        sprite.position.y = 0.8;

        group.add(sprite);
    }

    createConnections() {
        // Create connection lines between satellites and central node
        this.satellites.forEach(satellite => {
            const geometry = new THREE.BufferGeometry();
            const material = new THREE.LineBasicMaterial({
                color: this.getStatusColor(satellite.data.status),
                transparent: true,
                opacity: 0.3
            });

            const line = new THREE.Line(geometry, material);
            this.connections.push({
                line: line,
                satellite: satellite,
                geometry: geometry
            });

            this.scene.add(line);
        });
    }

    setupLighting() {
        // Ambient light
        const ambientLight = new THREE.AmbientLight(0x404040, 0.4);
        this.scene.add(ambientLight);

        // Directional light
        const directionalLight = new THREE.DirectionalLight(0xffffff, 0.8);
        directionalLight.position.set(10, 10, 5);
        directionalLight.castShadow = true;
        this.scene.add(directionalLight);

        // Point lights for dramatic effect
        const pointLight1 = new THREE.PointLight(0x6F4E37, 0.5, 20);
        pointLight1.position.set(0, 5, 0);
        this.scene.add(pointLight1);
    }

    setupControls() {
        this.controls = new THREE.OrbitControls(this.camera, this.renderer.domElement);
        this.controls.enableDamping = true;
        this.controls.dampingFactor = 0.05;
        this.controls.maxDistance = 30;
        this.controls.minDistance = 5;

        // Add mouse interaction
        this.raycaster = new THREE.Raycaster();
        this.mouse = new THREE.Vector2();

        this.renderer.domElement.addEventListener('click', (event) => this.onMouseClick(event));
        this.renderer.domElement.addEventListener('mousemove', (event) => this.onMouseMove(event));
    }

    onMouseClick(event) {
        // Calculate mouse position in normalized device coordinates
        this.mouse.x = (event.clientX / window.innerWidth) * 2 - 1;
        this.mouse.y = -(event.clientY / window.innerHeight) * 2 + 1;

        // Update the picking ray with the camera and mouse position
        this.raycaster.setFromCamera(this.mouse, this.camera);

        // Calculate objects intersecting the picking ray
        const clickableObjects = [...this.regions, ...this.satellites.map(s => s.mesh)];
        const intersects = this.raycaster.intersectObjects(clickableObjects);

        if (intersects.length > 0) {
            const clickedObject = intersects[0].object;
            this.handleObjectClick(clickedObject);
        }
    }

    onMouseMove(event) {
        // Calculate mouse position for hover effects
        this.mouse.x = (event.clientX / window.innerWidth) * 2 - 1;
        this.mouse.y = -(event.clientY / window.innerHeight) * 2 + 1;

        this.raycaster.setFromCamera(this.mouse, this.camera);

        const hoverableObjects = [...this.regions, ...this.satellites.map(s => s.mesh)];
        const intersects = this.raycaster.intersectObjects(hoverableObjects);

        // Reset all hover states
        this.regions.forEach(region => {
            region.scale.setScalar(1);
        });
        this.satellites.forEach(satellite => {
            satellite.mesh.scale.setScalar(1);
        });

        // Apply hover effect to intersected object
        if (intersects.length > 0) {
            const hoveredObject = intersects[0].object;
            hoveredObject.scale.setScalar(1.2);
            this.renderer.domElement.style.cursor = 'pointer';
        } else {
            this.renderer.domElement.style.cursor = 'default';
        }
    }

    handleObjectClick(object) {
        if (object.userData.name) {
            // Clicked on a region
            this.updateInfoPanel({
                name: `${object.userData.name} Region`,
                type: 'region',
                status: object.userData.status
            });

            // Send message to Flutter
            if (window.FlutterChannel) {
                window.FlutterChannel.postMessage(`region_clicked:${object.userData.name}`);
            }

            // Create pulse effect from all satellites to this region
            this.satellites.forEach(satellite => {
                this.createPulse(satellite, object);
            });
        } else {
            // Clicked on a satellite
            const satellite = this.satellites.find(s => s.mesh === object);
            if (satellite) {
                this.updateInfoPanel(satellite.data);

                // Send message to Flutter
                if (window.FlutterChannel) {
                    window.FlutterChannel.postMessage(`satellite_clicked:${satellite.data.type}`);
                }

                // Create pulse to random region
                const randomRegion = this.regions[Math.floor(Math.random() * this.regions.length)];
                this.createPulse(satellite, randomRegion);
            }
        }
    }

    addGlowEffect(mesh, color) {
        const geometry = mesh.geometry.clone();
        const material = new THREE.MeshBasicMaterial({
            color: color,
            transparent: true,
            opacity: 0.2,
            side: THREE.BackSide
        });

        const glow = new THREE.Mesh(geometry, material);
        glow.scale.multiplyScalar(1.5);
        glow.position.copy(mesh.position);

        this.scene.add(glow);
    }

    getStatusColor(status) {
        switch (status) {
            case 'opportunity': return 0x4CAF50; // Green
            case 'watch': return 0xFFC107; // Yellow
            case 'threat': return 0xF44336; // Red
            default: return 0x6F4E37; // Coffee brown
        }
    }

    updateSatellitePositions() {
        this.satellites.forEach((satellite, index) => {
            const angle = satellite.data.angle + this.time * this.orbitSpeed;
            const x = Math.cos(angle) * this.orbitRadius;
            const z = Math.sin(angle) * this.orbitRadius;
            const y = Math.sin(this.time * 0.02 + index) * 0.5 + 2;

            satellite.group.position.set(x, y, z);

            // Rotate satellite
            satellite.mesh.rotation.y += 0.02;

            // Animate particles
            if (satellite.group.userData.particles) {
                satellite.group.userData.particles.rotation.y += 0.01;
            }
        });
    }

    updateConnections() {
        this.connections.forEach(connection => {
            const positions = [];

            // Start from satellite
            const satPos = connection.satellite.group.position;
            positions.push(satPos.x, satPos.y, satPos.z);

            // End at central node
            positions.push(0, 0, 0);

            connection.geometry.setAttribute(
                'position',
                new THREE.Float32BufferAttribute(positions, 3)
            );

            // Animate connection opacity based on data activity
            const opacity = 0.3 + Math.sin(this.time * 0.05) * 0.2;
            connection.line.material.opacity = opacity;
        });
    }

    createPulse(fromSatellite, toRegion) {
        // Create pulse effect when correlation is detected
        const geometry = new THREE.SphereGeometry(0.05, 8, 8);
        const material = new THREE.MeshBasicMaterial({
            color: 0xFFFFFF,
            transparent: true,
            opacity: 1
        });

        const pulse = new THREE.Mesh(geometry, material);
        pulse.position.copy(fromSatellite.group.position);

        this.scene.add(pulse);
        this.pulses.push({
            mesh: pulse,
            startPos: fromSatellite.group.position.clone(),
            endPos: toRegion.position.clone(),
            progress: 0
        });
    }

    updatePulses() {
        this.pulses.forEach((pulse, index) => {
            pulse.progress += 0.02;

            if (pulse.progress >= 1) {
                this.scene.remove(pulse.mesh);
                this.pulses.splice(index, 1);
                return;
            }

            // Interpolate position
            pulse.mesh.position.lerpVectors(
                pulse.startPos,
                pulse.endPos,
                pulse.progress
            );

            // Fade out
            pulse.mesh.material.opacity = 1 - pulse.progress;
            pulse.mesh.scale.setScalar(1 + pulse.progress * 2);
        });
    }

    simulateDataStreams() {
        // Start real data updates
        this.startRealDataUpdates();

        // Simulate real-time data updates with more realistic patterns
        setInterval(() => {
            // Simulate coffee price correlation with weather
            if (Math.random() < 0.4) {
                const weatherSat = this.satellites.find(s => s.data.type === 'weather');
                const priceSat = this.satellites.find(s => s.data.type === 'prices');

                if (weatherSat && priceSat) {
                    // Weather affects prices - create correlation
                    this.createPulse(weatherSat, this.regions[0]);
                    setTimeout(() => {
                        this.createPulse(priceSat, this.regions[0]);
                        this.updateInfoPanel({
                            name: 'Correlation Detected',
                            type: 'correlation',
                            status: 'watch'
                        });
                    }, 1000);
                }
            }

            // Simulate disease outbreak spreading
            if (Math.random() < 0.2) {
                const diseaseSat = this.satellites.find(s => s.data.type === 'disease');
                if (diseaseSat) {
                    // Disease spreads to multiple regions
                    this.regions.forEach((region, index) => {
                        setTimeout(() => {
                            this.createPulse(diseaseSat, region);
                            region.material.color.setHex(0xF44336); // Red alert
                        }, index * 500);
                    });

                    this.updateInfoPanel({
                        name: 'Disease Alert',
                        type: 'disease',
                        status: 'threat'
                    });
                }
            }

            // Update satellite statuses with more realistic logic
            this.satellites.forEach(satellite => {
                if (Math.random() < 0.15) {
                    let newStatus;

                    // More realistic status changes based on type
                    switch (satellite.data.type) {
                        case 'prices':
                            newStatus = Math.random() < 0.6 ? 'threat' : 'watch';
                            break;
                        case 'weather':
                            newStatus = Math.random() < 0.4 ? 'threat' : 'opportunity';
                            break;
                        case 'disease':
                            newStatus = Math.random() < 0.7 ? 'threat' : 'watch';
                            break;
                        default:
                            const statuses = ['opportunity', 'watch', 'threat'];
                            newStatus = statuses[Math.floor(Math.random() * statuses.length)];
                    }

                    satellite.data.status = newStatus;

                    const newColor = this.getStatusColor(newStatus);
                    satellite.mesh.material.color.setHex(newColor);
                    satellite.mesh.material.emissive.setHex(newColor);

                    // Update connection line color
                    const connection = this.connections.find(c => c.satellite === satellite);
                    if (connection) {
                        connection.line.material.color.setHex(newColor);
                    }
                }
            });
        }, 2500);

        // Add periodic "intelligence bursts" - rapid fire correlations
        setInterval(() => {
            if (Math.random() < 0.3) {
                this.triggerIntelligenceBurst();
            }
        }, 8000);
    }

    async startRealDataUpdates() {
        // Update real data every 5 minutes
        const updateRealData = async () => {
            try {
                // Fetch weather data
                const weatherData = await this.dataService.getCachedData(
                    'weather',
                    () => this.dataService.fetchWeatherData()
                );
                this.processWeatherData(weatherData);

                // Fetch coffee price data
                const priceData = await this.dataService.getCachedData(
                    'coffee',
                    () => this.dataService.fetchCoffeePrice()
                );
                this.processPriceData(priceData);

                // Fetch currency data
                const currencyData = await this.dataService.getCachedData(
                    'currency',
                    () => this.dataService.fetchCurrencyRates()
                );
                this.processCurrencyData(currencyData);

                // Fetch news data
                const newsData = await this.dataService.getCachedData(
                    'news',
                    () => this.dataService.fetchNewsData()
                );
                this.processNewsData(newsData);

            } catch (error) {
                console.warn('Real data update failed:', error);
            }
        };

        // Initial update
        updateRealData();

        // Set up periodic updates
        setInterval(updateRealData, 300000); // 5 minutes
    }

    processWeatherData(weatherData) {
        const weatherSat = this.satellites.find(s => s.data.type === 'weather');
        if (weatherSat && weatherData.length > 0) {
            // Determine overall weather status
            const avgTemp = weatherData.reduce((sum, w) => sum + w.temperature, 0) / weatherData.length;
            const hasStorms = weatherData.some(w => w.condition.includes('storm') || w.condition.includes('rain'));

            let status = 'opportunity';
            if (hasStorms || avgTemp > 30 || avgTemp < 15) {
                status = 'threat';
            } else if (avgTemp > 25 || avgTemp < 18) {
                status = 'watch';
            }

            this.updateSatelliteStatus(weatherSat, status);

            // Update info panel with real weather data
            const message = `Real weather: ${weatherData[0].region} ${avgTemp.toFixed(1)}°C, ${weatherData[0].condition}`;
            this.updateInfoPanel({
                name: 'Weather Data',
                type: 'weather',
                status: status,
                customMessage: message
            });
        }
    }

    processPriceData(priceData) {
        const priceSat = this.satellites.find(s => s.data.type === 'prices');
        if (priceSat && priceData) {
            let status = 'opportunity';
            if (priceData.change24h < -0.05) {
                status = 'threat';
            } else if (Math.abs(priceData.change24h) > 0.02) {
                status = 'watch';
            }

            this.updateSatelliteStatus(priceSat, status);

            const message = `Real coffee price: $${priceData.current.toFixed(3)}/lb (${priceData.change24h > 0 ? '+' : ''}${(priceData.change24h * 100).toFixed(2)}%)`;
            this.updateInfoPanel({
                name: 'Coffee Prices',
                type: 'prices',
                status: status,
                customMessage: message
            });
        }
    }

    processCurrencyData(currencyData) {
        const currencySat = this.satellites.find(s => s.data.type === 'currency');
        if (currencySat && currencyData) {
            let status = 'opportunity';
            if (currencyData.change24h < -20) {
                status = 'threat';
            } else if (Math.abs(currencyData.change24h) > 10) {
                status = 'watch';
            }

            this.updateSatelliteStatus(currencySat, status);

            const message = `USD/BIF: ${currencyData.usdToBif.toFixed(0)} (${currencyData.change24h > 0 ? '+' : ''}${currencyData.change24h.toFixed(1)})`;
            this.updateInfoPanel({
                name: 'Exchange Rates',
                type: 'currency',
                status: status,
                customMessage: message
            });
        }
    }

    processNewsData(newsData) {
        const newsSat = this.satellites.find(s => s.data.type === 'news');
        if (newsSat && newsData.length > 0) {
            // Analyze overall sentiment
            const sentiments = newsData.map(n => n.sentiment);
            const threatCount = sentiments.filter(s => s === 'threat').length;
            const opportunityCount = sentiments.filter(s => s === 'opportunity').length;

            let status = 'watch';
            if (opportunityCount > threatCount) {
                status = 'opportunity';
            } else if (threatCount > opportunityCount) {
                status = 'threat';
            }

            this.updateSatelliteStatus(newsSat, status);

            const latestNews = newsData[0];
            this.updateInfoPanel({
                name: 'News Feed',
                type: 'news',
                status: status,
                customMessage: `Latest: ${latestNews.title.substring(0, 60)}...`
            });
        }
    }

    updateSatelliteStatus(satellite, newStatus) {
        satellite.data.status = newStatus;
        const newColor = this.getStatusColor(newStatus);
        satellite.mesh.material.color.setHex(newColor);
        satellite.mesh.material.emissive.setHex(newColor);

        // Update connection line color
        const connection = this.connections.find(c => c.satellite === satellite);
        if (connection) {
            connection.line.material.color.setHex(newColor);
        }

        // Create pulse to show update
        const randomRegion = this.regions[Math.floor(Math.random() * this.regions.length)];
        this.createPulse(satellite, randomRegion);
    }

    triggerIntelligenceBurst() {
        // Rapid fire correlations showing AI analysis
        const burstCount = 3 + Math.floor(Math.random() * 3);

        for (let i = 0; i < burstCount; i++) {
            setTimeout(() => {
                const randomSat = this.satellites[Math.floor(Math.random() * this.satellites.length)];
                const randomRegion = this.regions[Math.floor(Math.random() * this.regions.length)];
                this.createPulse(randomSat, randomRegion);

                // Flash the central node
                this.centralNode.material.emissiveIntensity = 0.5;
                setTimeout(() => {
                    this.centralNode.material.emissiveIntensity = 0;
                }, 200);
            }, i * 300);
        }

        this.updateInfoPanel({
            name: 'AI Analysis',
            type: 'ai',
            status: 'opportunity'
        });
    }

    updateInfoPanel(satelliteData) {
        const panel = document.getElementById('data-streams');
        const statusClass = satelliteData.status;

        const messages = {
            prices: [
                'ICO prices down 12% - Brazil drought impact',
                'Arabica futures spike +8% on supply concerns',
                'Vietnam robusta exports delayed - opportunity window',
                'NY Coffee futures hit 3-month high',
                'Burundi premium grade +15% vs benchmark'
            ],
            weather: [
                'Satellite imagery: Heavy rains approaching Kayanza',
                'Drought conditions detected in Ngozi province',
                'Optimal harvest weather window: 5 days remaining',
                'Temperature anomaly: +3°C above seasonal average',
                'Rainfall 40% below normal - irrigation recommended'
            ],
            disease: [
                'Coffee leaf rust detected via drone surveillance',
                'Fungal spore count elevated in Muyinga region',
                'Berry borer infestation spreading from Tanzania',
                'Resistant variety adoption recommended',
                'Organic treatment effectiveness: 78% success rate'
            ],
            market: [
                'Bujumbura auction: Premium grade +22% price jump',
                'Export permits processed: 847 tons this week',
                'Quality scores trending upward: avg 84.5 points',
                'Direct trade inquiries from EU buyers +35%',
                'Cooperative membership growing: 1,247 new farmers'
            ],
            news: [
                'Government announces coffee sector investment plan',
                'New processing facility opens in Kayanza',
                'International buyers delegation arriving next week',
                'Coffee export tax reduced by 2% - profit boost',
                'Sustainable certification program launched'
            ],
            currency: [
                'BIF strengthening: Export profits up 8%',
                'USD/BIF rate favorable for next 30 days',
                'Central bank intervention stabilizing rates',
                'Remittance flows supporting currency',
                'Regional currency union talks progressing'
            ],
            correlation: [
                'AI detected: Weather pattern → Price volatility',
                'Correlation found: Disease outbreak → Market shift',
                'Pattern match: Brazil frost → Burundi opportunity',
                'Supply chain disruption → Premium pricing window',
                'Quality scores correlate with rainfall patterns'
            ],
            ai: [
                'AI Analysis: Optimal selling window in 3-5 days',
                'Machine learning: 87% confidence price increase',
                'Predictive model: Harvest timing critical',
                'Algorithm suggests: Focus on premium grades',
                'Intelligence synthesis: Multiple positive signals'
            ]
        };

        const messageArray = messages[satelliteData.type] || ['Data stream active'];
        const message = satelliteData.customMessage || messageArray[Math.floor(Math.random() * messageArray.length)];

        const streamDiv = document.createElement('div');
        streamDiv.className = `data-stream ${statusClass}`;
        streamDiv.innerHTML = `<strong>${satelliteData.name}:</strong> ${message}`;

        // Add timestamp
        const timestamp = new Date().toLocaleTimeString();
        const timeSpan = document.createElement('span');
        timeSpan.style.float = 'right';
        timeSpan.style.fontSize = '10px';
        timeSpan.style.opacity = '0.7';
        timeSpan.textContent = timestamp;
        streamDiv.appendChild(timeSpan);

        panel.appendChild(streamDiv);

        // Keep only last 6 messages
        while (panel.children.length > 6) {
            panel.removeChild(panel.firstChild);
        }

        // Auto-scroll to latest message
        panel.scrollTop = panel.scrollHeight;
    }

    animate() {
        requestAnimationFrame(() => this.animate());

        this.time += 0.016; // ~60fps

        // Update satellite positions
        this.updateSatellitePositions();

        // Update connections
        this.updateConnections();

        // Update pulses
        this.updatePulses();

        // Animate pulsing ring
        if (this.pulsingRing) {
            const scale = 1 + Math.sin(this.time * 2) * 0.1;
            this.pulsingRing.scale.set(scale, scale, scale);
        }

        // Update atmosphere shader
        if (this.atmosphere) {
            this.atmosphere.material.uniforms.time.value = this.time;
        }

        // Dynamic bloom intensity based on activity
        if (this.bloomPass) {
            const activity = this.pulses.length / 10; // More pulses = more bloom
            this.bloomPass.strength = 1.5 + activity * 0.5;
        }

        // Update controls
        this.controls.update();

        // Render with postprocessing
        if (this.composer) {
            this.composer.render();
        } else {
            this.renderer.render(this.scene, this.camera);
        }
    }

    onWindowResize() {
        this.camera.aspect = window.innerWidth / window.innerHeight;
        this.camera.updateProjectionMatrix();
        this.renderer.setSize(window.innerWidth, window.innerHeight);

        if (this.composer) {
            this.composer.setSize(window.innerWidth, window.innerHeight);
        }
    }
}

// Real Data Service for API integration
class RealDataService {
    constructor() {
        this.apiKeys = {
            weather: 'YOUR_OPENWEATHER_API_KEY',
            currency: 'YOUR_CURRENCY_API_KEY',
            news: 'YOUR_NEWS_API_KEY'
        };

        this.endpoints = {
            weather: 'https://api.openweathermap.org/data/2.5/weather',
            currency: 'https://api.exchangerate-api.com/v4/latest/USD',
            coffee: 'https://api.iextrading.com/1.0/stock/JO/quote',
            news: 'https://newsapi.org/v2/everything'
        };

        this.cache = new Map();
        this.lastUpdate = new Map();
    }

    async fetchWeatherData() {
        try {
            const regions = [
                { name: 'Kayanza', lat: -2.9, lon: 29.6 },
                { name: 'Ngozi', lat: -2.9, lon: 29.8 },
                { name: 'Muyinga', lat: -2.8, lon: 30.3 }
            ];

            const weatherPromises = regions.map(async (region) => {
                const url = `${this.endpoints.weather}?lat=${region.lat}&lon=${region.lon}&appid=${this.apiKeys.weather}&units=metric`;
                const response = await fetch(url);
                const data = await response.json();

                return {
                    region: region.name,
                    temperature: data.main.temp,
                    condition: data.weather[0].description,
                    humidity: data.main.humidity,
                    windSpeed: data.wind.speed,
                    pressure: data.main.pressure
                };
            });

            return await Promise.all(weatherPromises);
        } catch (error) {
            console.warn('Weather API failed, using mock data:', error);
            return this.getMockWeatherData();
        }
    }

    async fetchCoffeePrice() {
        try {
            // Using a free coffee futures API or commodity API
            const response = await fetch('https://api.marketstack.com/v1/eod/latest?access_key=YOUR_KEY&symbols=KC.XCEC');
            const data = await response.json();

            return {
                current: data.data[0].close,
                change24h: data.data[0].close - data.data[0].open,
                volume: data.data[0].volume,
                timestamp: new Date(data.data[0].date)
            };
        } catch (error) {
            console.warn('Coffee price API failed, using mock data:', error);
            return this.getMockCoffeePrice();
        }
    }

    async fetchCurrencyRates() {
        try {
            const response = await fetch(`${this.endpoints.currency}`);
            const data = await response.json();

            return {
                usdToBif: data.rates.BIF || 2000, // Approximate BIF rate
                change24h: Math.random() * 50 - 25, // Mock change
                timestamp: new Date()
            };
        } catch (error) {
            console.warn('Currency API failed, using mock data:', error);
            return this.getMockCurrencyData();
        }
    }

    async fetchNewsData() {
        try {
            const query = 'coffee OR Burundi OR agriculture';
            const url = `${this.endpoints.news}?q=${query}&apiKey=${this.apiKeys.news}&pageSize=5`;
            const response = await fetch(url);
            const data = await response.json();

            return data.articles.map(article => ({
                title: article.title,
                description: article.description,
                source: article.source.name,
                publishedAt: new Date(article.publishedAt),
                sentiment: this.analyzeSentiment(article.title + ' ' + article.description)
            }));
        } catch (error) {
            console.warn('News API failed, using mock data:', error);
            return this.getMockNewsData();
        }
    }

    analyzeSentiment(text) {
        // Simple sentiment analysis
        const positiveWords = ['good', 'increase', 'growth', 'profit', 'success', 'opportunity'];
        const negativeWords = ['bad', 'decrease', 'loss', 'crisis', 'threat', 'problem'];

        const lowerText = text.toLowerCase();
        const positiveCount = positiveWords.filter(word => lowerText.includes(word)).length;
        const negativeCount = negativeWords.filter(word => lowerText.includes(word)).length;

        if (positiveCount > negativeCount) return 'opportunity';
        if (negativeCount > positiveCount) return 'threat';
        return 'watch';
    }

    // Mock data fallbacks
    getMockWeatherData() {
        return [
            { region: 'Kayanza', temperature: 22 + Math.random() * 8, condition: 'partly cloudy', humidity: 65 + Math.random() * 20 },
            { region: 'Ngozi', temperature: 20 + Math.random() * 8, condition: 'sunny', humidity: 60 + Math.random() * 20 },
            { region: 'Muyinga', temperature: 24 + Math.random() * 8, condition: 'cloudy', humidity: 70 + Math.random() * 20 }
        ];
    }

    getMockCoffeePrice() {
        return {
            current: 1.20 + Math.random() * 0.5,
            change24h: (Math.random() - 0.5) * 0.1,
            volume: 10000 + Math.random() * 5000,
            timestamp: new Date()
        };
    }

    getMockCurrencyData() {
        return {
            usdToBif: 2000 + Math.random() * 100,
            change24h: (Math.random() - 0.5) * 50,
            timestamp: new Date()
        };
    }

    getMockNewsData() {
        const mockNews = [
            { title: 'Coffee prices surge on supply concerns', sentiment: 'opportunity' },
            { title: 'Weather patterns favor coffee harvest', sentiment: 'opportunity' },
            { title: 'Disease outbreak threatens crops', sentiment: 'threat' },
            { title: 'New export agreements signed', sentiment: 'opportunity' },
            { title: 'Market volatility continues', sentiment: 'watch' }
        ];

        return mockNews.map(news => ({
            ...news,
            description: `Latest developments in ${news.title.toLowerCase()}`,
            source: 'AgriNews',
            publishedAt: new Date()
        }));
    }

    // Cache management
    async getCachedData(key, fetchFunction, cacheTime = 300000) { // 5 minutes default
        const now = Date.now();
        const lastUpdate = this.lastUpdate.get(key) || 0;

        if (now - lastUpdate < cacheTime && this.cache.has(key)) {
            return this.cache.get(key);
        }

        const data = await fetchFunction();
        this.cache.set(key, data);
        this.lastUpdate.set(key, now);

        return data;
    }
}

// Initialize the 3D visualization
document.addEventListener('DOMContentLoaded', () => {
    window.agriPulse3D = new AgriPulse3D();
});