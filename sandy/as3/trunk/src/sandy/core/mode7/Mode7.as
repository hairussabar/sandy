
{
	import sandy.core.Scene3D;
	{
		private var _width : Number;
		private var _height : Number;

		private var _numLines : int;

		private var _fov : Number;
		private var _near : Number;
		private var _far : Number;
		private var _useCameraNearFar : Boolean;
		private var _ratioWidthHeight : Number;
		private var _altitude : Number;
		private var _camTiltRadian : Number;

		private var _traceHorizon : Boolean;
		private var _colorHorizon : int;
		private var _widthHorizon : Number;

		private var _scaleMap : Number;
		private var _repeatMap : Boolean;
		private var _smooth : Boolean;
		private var _centerMapMatrix : Matrix;
		private var _mapMatrix : Matrix;
		private var _lineMatrix : Matrix;

		private var _yMin : Number;
		private var _length : Number;
		private var _yMaxTilted : Number;
		private var _yMinTilted : Number;
		private var _yLength : Number;
		private var _yStep : Number;
		private var _yCurrent : Number;
		private var _zMax : Number;
		private var _zMin : Number;
		private var _zMaxTilted : Number;
		private var _zMinTilted : Number;
		private var _zLength : Number;
		private var _zStep : Number;
		private var _zCurrent : Number;
		private var _t : Number;
		private var _xAmplitude : Number;
		private var _xAmplitudePrev : Number;
		private var _xAmplitudeAvg : Number;
		private var _zAmplitude : Number;
		private var _zProj : Number;
		private var _zProjPrev : Number;
		private var _prevOK : Boolean;

		private const PIon180 : Number = PI / 180;
		private const cos : Function = Math.cos;
		private const sin : Function = Math.sin;
		private const tan : Function = Math.tan;

		{
			_useCameraNearFar = true;
			_lineMatrix = new Matrix();
			setHorizon();
		}


		{		
			return _smooth;		
		}

		{		
			_smooth = value;		
		}

		{		
			return _repeatMap;		
		}

		{		
			_repeatMap = value;		
		}

		{
			_mapOriginal = bmp;
			_scaleMap = scale;
			_repeatMap = repeatMap;
			_smooth = smooth;
			_centerMapMatrix = new Matrix();
			_centerMapMatrix.translate(-bmp.width / 2, -bmp.height / 2);
			_centerMapMatrix.scale(_scaleMap, -_scaleMap);
			_mapMatrix = new Matrix();
		}

		{
			_traceHorizon = traceHorizon;
			_colorHorizon = colorHorizon;
			_widthHorizon = horizonWidth;
		}

		{		
			return _horizon;			
		}

		{
			_useCameraNearFar = fromCamera;
			if (!_useCameraNearFar)
			{
				_near = near;
				_far = far;
			}
		}

		{
			_camera = p_oCamera;
			_width = p_oCamera.viewport.width;
			_height = p_oCamera.viewport.height;
			_ratioWidthHeight = _width / _height;
			_container = p_oScene.container;
			_numLines = _height;
			// --
			_mapMatrix.identity();
			_mapMatrix.concat(_centerMapMatrix);
			_mapMatrix.translate(-_camera.x, -_camera.z);
			_mapMatrix.rotate(-PIon180 * _camera.rotateY);
			
			_fov = PIon180 * _camera.fov;
			if (_useCameraNearFar)
			{
				_near = _camera.near;
				_far = _camera.far;
			}
			_altitude = _camera.y;
			_camTiltRadian = PIon180 * _camera.tilt;
			
			_yMax = 1 / tan((PI - _fov) / 2);
			_yMin = -_yMax;
			_length = _yMax - _yMin;
			_zMax = 1;
			_zMin = 1;
			_yMaxTilted = _zMax * sin(-_camTiltRadian) + _yMax * cos(-_camTiltRadian);
			_zMaxTilted = _zMax * cos(-_camTiltRadian) - _yMax * sin(-_camTiltRadian);
			_yMinTilted = _zMin * sin(-_camTiltRadian) + _yMin * cos(-_camTiltRadian);
			_zMinTilted = _zMin * cos(-_camTiltRadian) - _yMin * sin(-_camTiltRadian);
			_yLength = _yMaxTilted - _yMinTilted;
			_yStep = _yLength / _numLines;
			_zLength = _zMaxTilted - _zMinTilted;
			_zStep = _zLength / _numLines;
			
			if (_yMaxTilted - _yMinTilted == 0)
			{
				if (_zMinTilted < _zMaxTilted)
				{
					_horizon = Number.NEGATIVE_INFINITY;
				}
				else if (_zMinTilted > _zMaxTilted)
				{
					_horizon = Number.POSITIVE_INFINITY;
				}
			}
			else
			{
				_horizon = _height * _yMaxTilted / (_yMaxTilted - _yMinTilted);
			}
			_camera.horizon = _horizon;
			
			_container.graphics.clear();
			_prevOK = false;
			var i : int;
			for (i = 0;i <= _numLines; i++)
			{
				_yCurrent = _altitude + _yMinTilted + i * _yStep;
				_zCurrent = _zMinTilted + i * _zStep;
				
				if (_yCurrent - _altitude != 0)
				{
					_t = -_altitude / (_yCurrent - _altitude);
					if (_t >= _near)
					{
						_zProj = _t * _zCurrent;
						_xAmplitude = _t * _ratioWidthHeight * _length;
						if (_prevOK)
						{
							if (_t <= _far)
							{
								_zAmplitude = _zProj - _zProjPrev;
								_xAmplitudeAvg = ( _xAmplitude + _xAmplitudePrev) / 2;
								_lineMatrix.identity();
								_lineMatrix.concat(_mapMatrix);
								_lineMatrix.translate(_xAmplitudeAvg / 2, (i - _height) * _zAmplitude - _zProj);
								_lineMatrix.scale(_width / _xAmplitudeAvg, -1 / _zAmplitude);
								_container.graphics.beginBitmapFill(_mapOriginal, _lineMatrix, _repeatMap, _smooth);
								_container.graphics.drawRect(0, _height - i, _width, 1);
								_container.graphics.endFill();
							}
							else
							{
								break;
							}
						}
						_zProjPrev = _zProj;
						_xAmplitudePrev = _xAmplitude;
						_prevOK = true;
					}
				}
			}
			
			if (_traceHorizon)
			{
				_container.graphics.lineStyle(_widthHorizon, _colorHorizon);
				_container.graphics.moveTo(0, _horizon);
				_container.graphics.lineTo(_width, _horizon);
			}						
		}
	}
}
