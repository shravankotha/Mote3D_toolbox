## Copyright (C) 2016 Henning Richter
##
## This function file is part of the 'Mote3D' toolbox for microstructure modelling.
##
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program. If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {@var{termflag} =} m3d_inputgen(@var{P_mat_ind}, @var{R_vec_ind},
## @var{box_length}, @var{termflag})
##
## Generate an input script for geometry import of the random particulate
## microstructure into Abaqus(TM) CAE software.
##
## Create an input script to recreate the spherical particles defined by particle
## centres @var{P_mat_ind} and particle radii @var{R_vec_ind} within the cubical
## domain with edge length @var{box_length} in Abaqus(TM) CAE.  Save this input
## script as "Abq_input_script.py".  Return the status flag @var{termflag}.
## @end deftypefn
## @cindex m3d_inputgen

## Author: Henning Richter <mote3d@quantentunnel.de>
## Created: April 2016
## Keywords: geometry input script, random periodic microstructure

function [termflag] = m3d_inputgen(P_mat_ind, R_vec_ind, box_length, termflag)

  ## Generate input script:
  fi2 = fopen("Abq_input_script.py", "wt");
  fprintf(fi2,"##\n");
  fprintf(fi2,"## Header:\n");
  fprintf(fi2,"## Abaqus(TM) CAE input script generated by Mote3D (www.github.com/Mote3D).\n");
  fprintf(fi2,"## Created on %s.\n", strftime("%a, %e %b %Y, at %T", localtime(time())));
  fprintf(fi2,"##\n");
  fprintf(fi2,"\n");
  fprintf(fi2,"\n");
  fprintf(fi2,"# Do not delete the following import lines:\n");
  fprintf(fi2,"from abaqus import *\n");
  fprintf(fi2,"from abaqusConstants import *\n");
  fprintf(fi2,"import __main__\n");
  fprintf(fi2,"\n");
  fprintf(fi2,"import section\n");
  fprintf(fi2,"import regionToolset\n");
  #fprintf(fi2,"import displayGroupMdbToolset as dgm\n");
  #fprintf(fi2,"import displayGroupOdbToolset as dgo\n");
  fprintf(fi2,"import sketch\n");
  fprintf(fi2,"import part\n");
  fprintf(fi2,"import assembly\n");
  fprintf(fi2,"import mesh\n");
  fprintf(fi2,"import visualization\n");
  fprintf(fi2,"import time\n");
  fprintf(fi2,"\n");
  fprintf(fi2,"\n");

  ## Initialize Model:
  fprintf(fi2,"##\n");
  fprintf(fi2,"## Model:\n");
  fprintf(fi2,"##\n");
  fprintf(fi2,"start = time.clock()\n");
  fprintf(fi2,"models = mdb.Model(name='Model-1')\n");
  fprintf(fi2,"\n");

  ## Save model parameters:
  fprintf(fi2,"##\n");
  fprintf(fi2,"## Model parameters:\n");
  fprintf(fi2,"##\n");
  fprintf(fi2,"box_length = %f\n", box_length);
  fprintf(fi2,"\n");
  fprintf(fi2,"part_cent = (\n");

  for (i=1:1:length(P_mat_ind(:,2)))
    fprintf(fi2,"    (%f, %f, %f),\n", P_mat_ind(i,2), P_mat_ind(i,3), P_mat_ind(i,4));
  endfor

  fprintf(fi2,"    )\n");
  fprintf(fi2,"\n");
  fprintf(fi2,"part_rad = (\n");
  fprintf(fi2,"    %f,\n", R_vec_ind(:,2));
  fprintf(fi2,"    )\n");
  fprintf(fi2,"\n");
  fprintf(fi2,"part_num = len(part_cent)\n");
  fprintf(fi2,"\n");

  ## Generate model:
  fprintf(fi2,"##\n");
  fprintf(fi2,"## Model generation:\n");
  fprintf(fi2,"##\n");
  fprintf(fi2,"for i in range (0, part_num, 1):\n");
  fprintf(fi2,"    \n");
  fprintf(fi2,"    s = mdb.models['Model-1'].ConstrainedSketch(name='__profile__',\n");
  fprintf(fi2,"        sheetSize=50.0)\n");
  fprintf(fi2,"    gs, vs, ds, cs = s.geometry, s.vertices, s.dimensions, s.constraints\n");
  fprintf(fi2,"    s.ConstructionLine(point1=(0.0, -10.0), point2=(0.0, 10.0))\n");
  fprintf(fi2,"    s.ArcByCenterEnds(center=(part_cent[i] [0], part_cent[i] [1]),\n");
  fprintf(fi2,"        point1=(part_cent[i] [0], part_cent[i] [1] + part_rad[i]),\n");
  fprintf(fi2,"        point2=(part_cent[i] [0], part_cent[i] [1] - part_rad[i]),\n");
  fprintf(fi2,"        direction=CLOCKWISE)\n");
  fprintf(fi2,"    s.Line(point1=(part_cent[i] [0], part_cent[i] [1] + part_rad[i]),\n");
  fprintf(fi2,"        point2=(part_cent[i] [0], part_cent[i] [1] - part_rad[i]))\n");
  fprintf(fi2,"    centerline = s.ConstructionLine(point1=(part_cent[i] [0], part_cent[i] [1]), angle=90.0)\n");
  fprintf(fi2,"    s.assignCenterline(line=centerline)\n");
  fprintf(fi2,"    \n");
  fprintf(fi2,"    p = mdb.models['Model-1'].Part(name='Particle-' + '%%d' %%(i+1), dimensionality=THREE_D,\n");
  fprintf(fi2,"        type=DEFORMABLE_BODY)\n");
  fprintf(fi2,"    p = mdb.models['Model-1'].parts['Particle-' + '%%d' %%(i+1)]\n");
  fprintf(fi2,"    p.BaseSolidRevolve(sketch=s, angle=360.0, flipRevolveDirection=OFF)\n");
  fprintf(fi2,"    \n");
  fprintf(fi2,"    ep, fp = p.edges, p.faces\n");
  fprintf(fi2,"    p.RemoveRedundantEntities(edgeList=(ep.findAt(coordinates=(part_cent[i] [0] + part_rad[i],\n");
  fprintf(fi2,"        part_cent[i] [1], 0.0)), ), removeEdgeVertices=True)\n");
  fprintf(fi2,"    \n");
  fprintf(fi2,"    p = mdb.models['Model-1'].parts['Particle-' + '%%d' %%(i+1)]\n");
  fprintf(fi2,"    vp, ep = p.vertices, p.edges\n");
  fprintf(fi2,"    p.DatumPlaneByPrincipalPlane(principalPlane=XYPLANE, offset = 0.0)\n");
  fprintf(fi2,"    p.DatumPlaneByPrincipalPlane(principalPlane=XZPLANE, offset = part_cent[i] [1])\n");
  fprintf(fi2,"    p = mdb.models['Model-1'].parts['Particle-' + '%%d' %%(i+1)]\n");
  fprintf(fi2,"    dp = p.datums\n");
  fprintf(fi2,"    p.DatumPlaneByRotation(plane=dp[3], axis=dp[1], angle=90.0)\n");
  fprintf(fi2,"    p = mdb.models['Model-1'].parts['Particle-' + '%%d' %%(i+1)]\n");
  fprintf(fi2,"    dp = p.datums\n");
  fprintf(fi2,"    cp = p.cells\n");
  fprintf(fi2,"    p.PartitionCellByDatumPlane(datumPlane=dp[3], cells=cp)\n");
  fprintf(fi2,"    cp = p.cells\n");
  fprintf(fi2,"    p.PartitionCellByDatumPlane(datumPlane=dp[4], cells=cp)\n");
  fprintf(fi2,"    cp = p.cells\n");
  fprintf(fi2,"    p.PartitionCellByDatumPlane(datumPlane=dp[5], cells=cp)\n");
  fprintf(fi2,"    \n");

  ## Create assembly:
  fprintf(fi2,"    ##\n");
  fprintf(fi2,"    ## Assembly:\n");
  fprintf(fi2,"    ##\n");
  fprintf(fi2,"    a = mdb.models['Model-1'].rootAssembly\n");
  fprintf(fi2,"    session.viewports['Viewport: 1'].setValues(displayedObject=a)\n");
  fprintf(fi2,"    session.viewports['Viewport: 1'].view.setViewpoint(viewVector=(1,1,1),\n");
  fprintf(fi2,"        cameraUpVector=(0,1,0))\n");
  fprintf(fi2,"    session.viewports['Viewport: 1'].view.zoom(zoomFactor=0.75, mode=ABSOLUTE)\n");
  fprintf(fi2,"    session.viewports['Viewport: 1'].assemblyDisplay.geometryOptions.setValues(\n");
  fprintf(fi2,"        datumPoints=OFF, datumAxes=OFF, datumPlanes=OFF, datumCoordSystems=OFF)\n");
  fprintf(fi2,"    a.DatumCsysByDefault(CARTESIAN)\n");
  fprintf(fi2,"    a = mdb.models['Model-1'].rootAssembly\n");
  fprintf(fi2,"    p = mdb.models['Model-1'].parts['Particle-' + '%%d' %%(i+1)]\n");
  fprintf(fi2,"    a.Instance(name='Particle-' + '%%d' %%(i+1) + '-1', part=p, dependent=OFF)\n");
  fprintf(fi2,"    a.translate(instanceList=('Particle-' + '%%d' %%(i+1) + '-1', ), vector=(0.0, 0.0, part_cent[i] [2]))\n");
  fprintf(fi2,"    \n");

  ## Merge particles:
  fprintf(fi2,"a = mdb.models['Model-1'].rootAssembly\n");
  fprintf(fi2,"a.DatumCsysByDefault(CARTESIAN)\n");
  fprintf(fi2,"a.InstanceFromBooleanMerge(name='Mote3D', instances=(\n");

  for (i=1:1:length(P_mat_ind(:,2)))
      fprintf(fi2,"    a.instances['Particle-%i-1'],\n", i);
  endfor

  fprintf(fi2,"    ),\n");
  fprintf(fi2,"    keepIntersections=OFF, originalInstances=SUPPRESS, domain=GEOMETRY)\n");
  fprintf(fi2,"a = mdb.models['Model-1'].rootAssembly\n");
  fprintf(fi2,"a.makeIndependent(instances=(a.instances['Mote3D-1'], ))\n");
  fprintf(fi2,"\n");
  fprintf(fi2,"for iterator in range(1, (len(part_cent)+1), 1):\n");
  fprintf(fi2,"    del mdb.models['Model-1'].parts['Particle-' + '%%d' %%iterator]\n");
  fprintf(fi2,"    \n");
  fprintf(fi2,"for iterator in range(1, (len(part_cent)+1), 1):\n");
  fprintf(fi2,"    del mdb.models['Model-1'].rootAssembly.instances['Particle-' + '%%d' %%iterator + '-1']\n");
  fprintf(fi2,"    \n");

  ## Create cubical domain:
  fprintf(fi2,"p = mdb.models['Model-1'].parts['Mote3D']\n");
  fprintf(fi2,"cube_datum = p.DatumCsysByThreePoints(name='Datum RVE', coordSysType=CARTESIAN, origin=(\n");
  fprintf(fi2,"    0.0, 0.0, 0.0), line1=(1.0, 0.0, 0.0), line2=(0.0, 1.0, 0.0))\n");
  fprintf(fi2,"cube_xyplane = p.DatumPlaneByPrincipalPlane(principalPlane=XYPLANE, offset=%f)\n", 4*box_length);
  fprintf(fi2,"cube_yzplane = p.DatumPlaneByPrincipalPlane(principalPlane=YZPLANE, offset=%f)\n", 4*box_length);
  fprintf(fi2,"p = mdb.models['Model-1'].parts['Mote3D']\n");
  fprintf(fi2,"t1 = p.MakeSketchTransform(sketchPlane=p.datums[cube_xyplane.id],\n");
  fprintf(fi2,"    sketchUpEdge=p.datums[cube_datum.id].axis1, sketchPlaneSide=SIDE1,\n");
  fprintf(fi2,"    sketchOrientation=BOTTOM, origin=(0.0, 0.0, 0.0))\n");
  fprintf(fi2,"s = mdb.models['Model-1'].ConstrainedSketch(name='__profile__',\n");
  fprintf(fi2,"    sheetSize=50.0, transform=t1)\n");
  fprintf(fi2,"s.rectangle(point1=(%f, %f), point2=(%f, %f))\n", box_length, box_length, 2*box_length, 2*box_length);
  fprintf(fi2,"s.rectangle(point1=(%f, %f), point2=(%f, %f))\n", -box_length, -box_length, 4*box_length, 4*box_length);
  fprintf(fi2,"p.CutExtrude(sketchPlane=p.datums[cube_xyplane.id],\n");
  fprintf(fi2,"    sketchUpEdge=p.datums[cube_datum.id].axis1, sketchPlaneSide=SIDE1,\n");
  fprintf(fi2,"    sketchOrientation=BOTTOM, sketch=s)\n");
  fprintf(fi2,"del mdb.models['Model-1'].sketches['__profile__']\n");
  fprintf(fi2,"\n");
  fprintf(fi2,"p = mdb.models['Model-1'].parts['Mote3D']\n");
  fprintf(fi2,"t2 = p.MakeSketchTransform(sketchPlane=p.datums[cube_yzplane.id],\n");
  fprintf(fi2,"    sketchUpEdge=p.datums[cube_datum.id].axis2, sketchPlaneSide=SIDE1,\n");
  fprintf(fi2,"    sketchOrientation=BOTTOM, origin=(0.0, 0.0, 0.0))\n");
  fprintf(fi2,"s = mdb.models['Model-1'].ConstrainedSketch(name='__profile__',\n");
  fprintf(fi2,"    sheetSize=50.0, transform=t2)\n");
  fprintf(fi2,"s.rectangle(point1=(%f, %f), point2=(%f, %f))\n", box_length, box_length, 2*box_length, 2*box_length);
  fprintf(fi2,"s.rectangle(point1=(%f, %f), point2=(%f, %f))\n", -box_length, -box_length, 4*box_length, 4*box_length);
  fprintf(fi2,"p.CutExtrude(sketchPlane=p.datums[cube_yzplane.id],\n");
  fprintf(fi2,"    sketchUpEdge=p.datums[cube_datum.id].axis2, sketchPlaneSide=SIDE1,\n");
  fprintf(fi2,"    sketchOrientation=BOTTOM, sketch=s)\n");
  fprintf(fi2,"del mdb.models['Model-1'].sketches['__profile__']\n");
  fprintf(fi2,"del cube_xyplane\n");
  fprintf(fi2,"del cube_yzplane\n");
  fprintf(fi2,"\n");
  fprintf(fi2,"a = mdb.models['Model-1'].rootAssembly\n");
  fprintf(fi2,"a.translate(instanceList=('Mote3D-1', ), vector=(-box_length, -box_length, -box_length))\n");
  fprintf(fi2,"a.regenerate()\n");
  fprintf(fi2,"\n");
  fprintf(fi2,"end = time.clock()\n");
  fprintf(fi2,"print 'Computation time [sec]:', (end-start)\n");
  fprintf(fi2,"\n");
  fclose(fi2);
  termflag = 1;

endfunction
