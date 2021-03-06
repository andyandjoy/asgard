// Generated by CoffeeScript 1.3.3
(function() {
  var AdminsModel, OperatorsModel, admins_model, adminsigin, operators_model, operatorsigin;

  admins_model = require('../model/admins-model');

  AdminsModel = admins_model.AdminsModel;

  operators_model = require('../model/operators-model');

  OperatorsModel = operators_model.OperatorsModel;

  exports.init = function(req, res) {
    return res.render('back-end/signin', {
      message: 'init'
    });
  };

  exports.signin = function(req, res) {
    var obj;
    console.log('-- asgard-signin(POST) -- ');
    console.log('req.body.username = ' + req.body.username);
    console.log('req.body.password = ' + req.body.password);
    console.log('req.body.role     = ' + req.body.role);
    console.log('req.body.remember = ' + req.body.remember);
    obj = {
      username: req.body.username,
      password: req.body.password,
      role: req.body.role,
      remember: req.body.remember
    };
    if (obj.role === 'admin') {
      return adminsigin(obj, req, res);
    } else {
      return operatorsigin(obj, req, res);
    }
  };

  adminsigin = function(obj, req, res) {
    var random;
    random = require('../libs/random').random;
    admins_model.once(random + '_admins_signin_success', function(result) {
      console.log('result_admins_signin_success = ' + result);
      if (result === null) {
        return res.render('back-end/signin', {
          message: '用户名/密码错误！'
        });
      } else {
        if (obj.remember === 'yes') {
          req.session.member = JSON.stringify(result);
        }
        res.cookie('member', JSON.stringify(result));
        return res.redirect('/dashboard');
      }
    });
    admins_model.once(random + '_admins_signin_error', function(error) {
      return console.log('result_admins_signin_error = ' + err);
    });
    return admins_model.find(AdminsModel, obj, random);
  };

  operatorsigin = function(obj, req, res) {
    var random;
    random = require('../libs/random').random;
    operators_model.once(random + '_operators_signin_success', function(result) {
      console.log('result_operators_signin_success = ' + result);
      if (result === null) {
        return res.render('back-end/signin', {
          message: '用户名/密码错误！'
        });
      } else {
        if (obj.remember === 'yes') {
          req.session.member = JSON.stringify(result);
        }
        res.cookie('member', JSON.stringify(result));
        return res.redirect('/dashboard');
      }
    });
    operators_model.once(random + '_operators_signin_error', function(error) {
      return console.log('result_operators_signin_error = ' + err);
    });
    return operators_model.find(OperatorsModel, obj, random);
  };

  exports.signout = function(req, res) {
    console.log('-- signout -- ');
    req.session.destroy();
    res.clearCookie('member');
    return res.redirect('/asgard-signin');
  };

}).call(this);
