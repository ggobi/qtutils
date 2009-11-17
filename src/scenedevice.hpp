
#ifndef QTDEVICE_SCENE_H
#define QTDEVICE_SCENE_H

#include <QWidget>
#include <QGraphicsScene>
#include <QGraphicsItem>


#include <R.h>
#include <Rinternals.h>
#define R_USE_PROTOTYPES 0
#include <R_ext/GraphicsEngine.h>
#include <R_ext/GraphicsDevice.h>


class RSceneDevice
{

 private:

    bool debug;
    bool force_repaint; // force view repaint after each piece is drawn
    double zclip;
    double zitem;
    int device_number;
    QString default_family;
    QGraphicsRectItem *clip_rect;
    QGraphicsScene *_scene;

 public:

    RSceneDevice(double width, double height, 
		 double pointsize, const char *family, 
		 QGraphicsScene *scene);
    // ~RSceneDevice(); 
    void setClipping(pDevDesc dev);
    void addClippedItem(QGraphicsItem *item);

    QString defaultFamily() { return default_family; }
    void setDeviceNumber(int n) { device_number = n; }
    int getDeviceNumber() { return device_number; }
    QGraphicsScene *scene() { return _scene; }

    void Circle(double x, double y, double r, 
		R_GE_gcontext *gc);
    void Line(double x1, double y1, double x2, double y2,
	      R_GE_gcontext *gc);
    void Polygon(int n, double *x, double *y,
		 R_GE_gcontext *gc);
    void Polyline(int n, double *x, double *y,
		  R_GE_gcontext *gc);
    void Rect(double x0, double y0, double x1, double y1,
	      R_GE_gcontext *gc);
    void TextUTF8(double x, double y, char *str,
		  double rot, double hadj,
		  R_GE_gcontext *gc);
    void NewPage(R_GE_gcontext *gc);
    void Mode(int mode);
    void MetricInfo(int c, R_GE_gcontext *gc,
		    double* ascent, double* descent,
		    double* width);
    double StrWidthUTF8(char *str, R_GE_gcontext *gc);

};



#endif
