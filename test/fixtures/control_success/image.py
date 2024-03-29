###################################################################
# This python script is used to generate images from a CFP job
# Author: Summer Wang at Ohio Supercomputer Center
# Date: 10/10/2013
# It runs on oakley where Paraview 3.14.1 is installed 
####################################################################

from paraview.simple import *
paraview.simple._DisableFirstRenderCameraReset()

test_foam = OpenFOAMReader( FileName='8.foam' )

AnimationScene1 = GetAnimationScene()
test_foam.CellArrays = ['U', 'alpha1', 'ccx', 'ccy', 'ccz', 'cellLevel', 'epsilon', 'k', 'nut', 'p', 'p_rgh']
test_foam.LagrangianArrays = []
test_foam.MeshRegions = ['walls_wall']
test_foam.PointArrays = ['pointLevel']

AnimationScene1.EndTime = 5 
AnimationScene1.PlayMode = 'Snap To TimeSteps'

test_foam.CaseType = 'Decomposed Case'

RenderView1 = GetRenderView()
DataRepresentation1 = Show()
DataRepresentation1.ScaleFactor = 0.10199999809265137
DataRepresentation1.EdgeColor = [0.0, 0.0, 0.50000762951094835]
DataRepresentation1.SelectionPointFieldDataArrayName = 'alpha1'
DataRepresentation1.SelectionCellFieldDataArrayName = 'alpha1'

test_foam = OpenFOAMReader( FileName='8.foam' )

#RenderView1.CameraPosition = [0.0, 0.0, 3.8784512065706922]
#RenderView1.CameraFocalPoint = [0.0, 0.0, 0.51000009523704648]
#RenderView1.CameraClippingRange = [2.3397668087201504, 4.6714776155453075]
#RenderView1.CenterOfRotation = [0.0, 0.0, 0.51000009523704648]
#RenderView1.CameraParallelScale = 0.87181930010989894

DataRepresentation1.Opacity = 0.5

test_foam.CellArrays = ['U', 'alpha1', 'ccx', 'ccy', 'ccz', 'cellLevel', 'epsilon', 'k', 'nut', 'p', 'p_rgh']
test_foam.LagrangianArrays = []
test_foam.MeshRegions = ['internalMesh']
test_foam.PointArrays = ['pointLevel']

test_foam.CaseType = 'Decomposed Case'

SetActiveSource(test_foam)
DataRepresentation2 = Show()
DataRepresentation2.EdgeColor = [0.0, 0.0, 0.50000762951094835]
DataRepresentation2.SelectionPointFieldDataArrayName = 'alpha1'
DataRepresentation2.SelectionCellFieldDataArrayName = 'alpha1'
DataRepresentation2.ScalarOpacityUnitDistance = 0.034607547270035559
DataRepresentation2.ExtractedBlockIndex = 1
DataRepresentation2.ScaleFactor = 0.10199999809265137

Contour1 = Contour( PointMergeMethod="Uniform Binning" )

DataRepresentation2.Visibility = 0

Contour1.PointMergeMethod = "Uniform Binning"
Contour1.ContourBy = ['POINTS', 'alpha1']
Contour1.Isosurfaces = [0.5]

DataRepresentation3 = Show()
DataRepresentation3.ScaleFactor = 0.058805201947689061
DataRepresentation3.EdgeColor = [0.0, 0.0, 0.50000762951094835]
DataRepresentation3.SelectionPointFieldDataArrayName = 'alpha1'
DataRepresentation3.SelectionCellFieldDataArrayName = 'alpha1'

AnnotateTime1 = AnnotateTime()

DataRepresentation4 = Show()

AnimationScene1.AnimationTime = 5

RenderView1.ViewTime = 5
RenderView1.CacheKey = 5
RenderView1.UseCache = 1

a3_U_PVLookupTable = GetLookupTableForArray( "U", 3, NanColor=[0.49803900000000001, 0.49803900000000001, 0.49803900000000001], RGBPoints=[0.0, 0.0, 0.0, 1.0, 3.0009595136322038, 1.0, 0.0, 0.0], VectorMode='Magnitude', ColorSpace='HSV', ScalarRangeInitialized=1.0 )

a3_U_PiecewiseFunction = CreatePiecewiseFunction( Points=[0.0, 0.0, 0.5, 0.0, 1.0, 1.0, 0.5, 0.0] )

ScalarBarWidgetRepresentation1 = CreateScalarBar( ComponentTitle='Magnitude', Title='U', Enabled=1, LabelFontSize=12, LookupTable=a3_U_PVLookupTable, TitleFontSize=12 )
GetRenderView().Representations.append(ScalarBarWidgetRepresentation1)

RenderView1.CameraViewUp = [0.018689859092566624, 0.94881869483330528, -0.31526778062771227]
RenderView1.CameraPosition = [-0.085131065341593232, 1.0633204287479956, 3.7050846413744152]
RenderView1.CameraClippingRange = [2.0454581448291633, 5.0419515869256637]
RenderView1.CameraPosition = [-0.085131065341593232, 1.0633204287479956, 3.7050846413744152]
ResetCamera()

DataRepresentation3.ColorArrayName = 'U'
DataRepresentation3.LookupTable = a3_U_PVLookupTable



AnimationScene1.AnimationTime = 0
RenderView1.ViewTime = 0
RenderView1.CacheKey = 0
RenderView1.UseCache = 1
WriteImage('images/t00.png')

AnimationScene1.AnimationTime = 1
RenderView1.ViewTime = 1
RenderView1.CacheKey = 1
RenderView1.UseCache = 1
WriteImage('images/t01.png')

AnimationScene1.AnimationTime = 2
RenderView1.ViewTime = 2
RenderView1.CacheKey = 2
RenderView1.UseCache = 1
WriteImage('images/t02.png')

AnimationScene1.AnimationTime = 3
RenderView1.ViewTime = 3
RenderView1.CacheKey = 3
RenderView1.UseCache = 1
WriteImage('images/t03.png')

AnimationScene1.AnimationTime = 4
RenderView1.ViewTime = 4
RenderView1.CacheKey = 4
RenderView1.UseCache = 1
WriteImage('images/t04.png')

AnimationScene1.AnimationTime = 5
RenderView1.ViewTime = 5
RenderView1.CacheKey = 5
RenderView1.UseCache = 1
WriteImage('images/t05.png')

RenderView1.UseCache = 0

Render()
