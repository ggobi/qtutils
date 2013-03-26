
#ifndef QTDEVICE_SCENE_H
#define QTDEVICE_SCENE_H

#include <Qt>
#include <QWidget>
#include <QGraphicsScene>
#include <QGraphicsItem>
#include <QEvent>
#include <QKeyEvent>
#include <QGraphicsSceneMouseEvent>


#include <R.h>
#include <Rinternals.h>
#define R_USE_PROTOTYPES 0
#include <R_ext/GraphicsEngine.h>
#include <R_ext/GraphicsDevice.h>





class GraphicsSceneWithEvents : public QGraphicsScene
{
    // Q_OBJECT // needed if signals/slots
    
    
private: 
    
    bool _wantKeyboardInput; 
    bool _wantMouseInput;
    // QKeyEvent *_lastKeyEvent;
    // QGraphicsSceneMouseEvent *_lastMouseEvent;
    bool handleKeyEvent(QKeyEvent *event) {
	if (_wantKeyboardInput) {
	    _wantKeyboardInput = false;
	    // _lastKeyEvent = event;
	    lastKeyType = event->type();
	    lastKeyKey = event->key();
	    lastKeyText = event->text();
	    return true;
	}
	else return false;
    }
    bool handleMouseEvent(QGraphicsSceneMouseEvent *event) {
	if (_wantMouseInput) {
	    _wantMouseInput = false;
	    // _lastMouseEvent = event;
	    lastMouseButton = event->button();
	    lastMousePos = event->scenePos();
	    lastMouseType = event->type();
	    return true;
	}
	else return false;
    }

public:

    GraphicsSceneWithEvents() : QGraphicsScene()  { 
	_wantKeyboardInput = false; 
	_wantMouseInput = false;
	// resetLastKeyEvent();
	// resetLastMouseEvent();
    }
    bool wantKeyboardInput() { return _wantKeyboardInput; }
    void setWantKeyboardInput(bool s) { _wantKeyboardInput = s; }
    bool wantMouseInput() { return _wantMouseInput; }
    void setWantMouseInput(bool s) { _wantMouseInput = s; }
    // QKeyEvent *lastKeyEvent() { return _lastKeyEvent; }
    // QGraphicsSceneMouseEvent *lastMouseEvent() { return _lastMouseEvent; }
    // void resetLastKeyEvent() { _lastKeyEvent = 0; }
    // void resetLastMouseEvent() { _lastMouseEvent = 0; }

    Qt::MouseButton lastMouseButton;
    QPointF lastMousePos;
    QEvent::Type lastMouseType;
    int lastKeyKey;
    QString lastKeyText;
    QEvent::Type lastKeyType;

protected:

    void keyPressEvent(QKeyEvent *event) {
	if (!handleKeyEvent(event)) QGraphicsScene::keyPressEvent(event);
	// FIXME: is this right way to pass event to parent?
    }
    void keyReleaseEvent(QKeyEvent *event) { if (!handleKeyEvent(event)) QGraphicsScene::keyPressEvent(event); }
    void mouseDoubleClickEvent(QGraphicsSceneMouseEvent *event) { if (!handleMouseEvent(event)) QGraphicsScene::mouseDoubleClickEvent(event); }
    void mouseMoveEvent(QGraphicsSceneMouseEvent *event) { if (!handleMouseEvent(event)) QGraphicsScene::mouseMoveEvent(event); }
    void mousePressEvent(QGraphicsSceneMouseEvent *event) { if (!handleMouseEvent(event)) QGraphicsScene::mousePressEvent(event); }
    void mouseReleaseEvent(QGraphicsSceneMouseEvent *event) { if (!handleMouseEvent(event)) QGraphicsScene::mouseReleaseEvent(event); }
    // void wheelEvent(QGraphicsSceneWheelEvent *event) if (!handleMouseEvent(event)) QGraphicsScene::w(event);


};



class RSceneDevice
{

 private:

    bool debug;
    bool force_repaint; // force view repaint after each piece is drawn?
    double zclip;
    double zitem;
    int device_number;
    QString default_family;
    QGraphicsRectItem *clip_rect;
    GraphicsSceneWithEvents *_scene;
    bool waitingForFrameConfirm;

 public:

    RSceneDevice(double width, double height, 
		 double pointsize, const char *family, 
		 GraphicsSceneWithEvents *scene);
    // ~RSceneDevice(); 
    void setClipping(pDevDesc dev);
    void addClippedItem(QGraphicsItem *item);

    QString defaultFamily() { return default_family; }
    void setDeviceNumber(int n) { device_number = n; }
    int getDeviceNumber() { return device_number; }
    GraphicsSceneWithEvents *scene() { return _scene; }

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
    void Activate();
    void Deactivate();
    void Close();
    void MetricInfo(int c, R_GE_gcontext *gc,
		    double* ascent, double* descent,
		    double* width);
    double StrWidthUTF8(char *str, R_GE_gcontext *gc);

    void ConfirmNewFrame();
    void EventHelper(int code, pDevDesc dev);
    bool LocateOnePoint(double *x, double *y);

public slots:

    void CheckFrameConfirm();

};



#endif
