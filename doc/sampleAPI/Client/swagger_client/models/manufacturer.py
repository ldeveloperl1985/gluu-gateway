# coding: utf-8

"""
    Simple Inventory API

    This is a simple API

    OpenAPI spec version: 1.0.0
    Contact: you@your-company.com
    Generated by: https://github.com/swagger-api/swagger-codegen.git

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
"""

from pprint import pformat
from six import iteritems
import re


class Manufacturer(object):
    """
    NOTE: This class is auto generated by the swagger code generator program.
    Do not edit the class manually.
    """
    def __init__(self, name=None, home_page=None, phone=None):
        """
        Manufacturer - a model defined in Swagger

        :param dict swaggerTypes: The key is attribute name
                                  and the value is attribute type.
        :param dict attributeMap: The key is attribute name
                                  and the value is json key in definition.
        """
        self.swagger_types = {
            'name': 'str',
            'home_page': 'str',
            'phone': 'str'
        }

        self.attribute_map = {
            'name': 'name',
            'home_page': 'homePage',
            'phone': 'phone'
        }

        self._name = name
        self._home_page = home_page
        self._phone = phone


    @property
    def name(self):
        """
        Gets the name of this Manufacturer.


        :return: The name of this Manufacturer.
        :rtype: str
        """
        return self._name

    @name.setter
    def name(self, name):
        """
        Sets the name of this Manufacturer.


        :param name: The name of this Manufacturer.
        :type: str
        """
        if name is None:
            raise ValueError("Invalid value for `name`, must not be `None`")

        self._name = name

    @property
    def home_page(self):
        """
        Gets the home_page of this Manufacturer.


        :return: The home_page of this Manufacturer.
        :rtype: str
        """
        return self._home_page

    @home_page.setter
    def home_page(self, home_page):
        """
        Sets the home_page of this Manufacturer.


        :param home_page: The home_page of this Manufacturer.
        :type: str
        """

        self._home_page = home_page

    @property
    def phone(self):
        """
        Gets the phone of this Manufacturer.


        :return: The phone of this Manufacturer.
        :rtype: str
        """
        return self._phone

    @phone.setter
    def phone(self, phone):
        """
        Sets the phone of this Manufacturer.


        :param phone: The phone of this Manufacturer.
        :type: str
        """

        self._phone = phone

    def to_dict(self):
        """
        Returns the model properties as a dict
        """
        result = {}

        for attr, _ in iteritems(self.swagger_types):
            value = getattr(self, attr)
            if isinstance(value, list):
                result[attr] = list(map(
                    lambda x: x.to_dict() if hasattr(x, "to_dict") else x,
                    value
                ))
            elif hasattr(value, "to_dict"):
                result[attr] = value.to_dict()
            elif isinstance(value, dict):
                result[attr] = dict(map(
                    lambda item: (item[0], item[1].to_dict())
                    if hasattr(item[1], "to_dict") else item,
                    value.items()
                ))
            else:
                result[attr] = value

        return result

    def to_str(self):
        """
        Returns the string representation of the model
        """
        return pformat(self.to_dict())

    def __repr__(self):
        """
        For `print` and `pprint`
        """
        return self.to_str()

    def __eq__(self, other):
        """
        Returns true if both objects are equal
        """
        return self.__dict__ == other.__dict__

    def __ne__(self, other):
        """
        Returns true if both objects are not equal
        """
        return not self == other